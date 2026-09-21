#!/usr/bin/env python3
"""PreToolUse hook: block file tools outside the paths listed in
~/.claude/allowed-dirs.json.

Unlike permissions.blockReadsOutsideWorkingDirectories, this does not trust
the launch cwd: it resolves the tool's actual target path and checks it
against the allowlist regardless of where Claude Code was started.

allowed-dirs.json separates "directories" from "files" because
permissions.additionalDirectories rejects non-directory entries; this hook
and the sandbox accept both.
"""
import json
import os
import sys

ALLOWED_DIRS_FILE = os.path.expanduser("~/.claude/allowed-dirs.json")
with open(ALLOWED_DIRS_FILE) as f:
    _allowed = json.load(f)
ALLOWED_ABS = [
    os.path.realpath(os.path.expanduser(p))
    for p in _allowed["directories"] + _allowed["files"]
]

PATH_FIELD_BY_TOOL = {
    "Read": "file_path",
    "Write": "file_path",
    "Edit": "file_path",
    "MultiEdit": "file_path",
    "NotebookEdit": "notebook_path",
}


def is_allowed(target: str) -> bool:
    return any(target == base or target.startswith(base + os.sep) for base in ALLOWED_ABS)


def main() -> int:
    data = json.load(sys.stdin)
    tool_name = data.get("tool_name", "")
    cwd = data.get("cwd") or os.getcwd()
    tool_input = data.get("tool_input") or {}

    if tool_name in ("Grep", "Glob"):
        target = tool_input.get("path") or cwd
    else:
        field = PATH_FIELD_BY_TOOL.get(tool_name)
        if field is None:
            return 0
        target = tool_input.get(field)
        if not target:
            return 0

    if not os.path.isabs(target):
        target = os.path.join(cwd, target)
    target = os.path.realpath(target)

    if not is_allowed(target):
        print(
            f"Blocked: {target} は許可ディレクトリ（~/src, ~/share/dotfiles 等）の外にあります",
            file=sys.stderr,
        )
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
