#!/usr/bin/env python3
"""PreToolUse hook: block write tools whose target path is outside the paths
listed in ~/.claude/allowed-dirs.json.

Registered only for Write/Edit/MultiEdit/NotebookEdit. The tool's actual
target path is resolved and checked, without trusting the launch cwd. The cwd
itself is checked by restrict-cwd.py.

Reads are deliberately not checked here: permissions.allow grants bare
Edit/Write, which leaves writes unbounded, but
permissions.blockReadsOutsideWorkingDirectories already fences Read/Grep/Glob
(and Bash file reads) to cwd + additionalDirectories in every permission mode,
including inside subagents (verified: a general-purpose subagent's Read of a
path outside the working directories was refused with the same error as the
parent). Combined with restrict-cwd.py, which keeps the cwd inside the
allowlist, that already confines reads to the allowlist.

Bash is deliberately not registered either: parsing an arbitrary shell command
string for the paths it touches isn't reliable (quoting, pipes, variable
expansion), so its filesystem access is left to sandbox.filesystem. Tools not
listed in PATH_FIELD_BY_TOOL are passed through.

Uses "tools" (directories) plus "files" (single files, since
permissions.additionalDirectories rejects non-directory entries) from
allowed-dirs.json. "sandboxExtra" (tool caches/state that only sandboxed Bash
needs) is deliberately not checked here.
"""
import json
import os
import sys

ALLOWED_DIRS_FILE = os.path.expanduser("~/.claude/allowed-dirs.json")

PATH_FIELD_BY_TOOL = {
    "Write": "file_path",
    "Edit": "file_path",
    "MultiEdit": "file_path",
    "NotebookEdit": "notebook_path",
}


def load_allowed() -> list[str]:
    with open(ALLOWED_DIRS_FILE) as f:
        allowed = json.load(f)
    return [
        os.path.realpath(os.path.expanduser(p))
        for p in allowed["tools"] + allowed["files"]
    ]


def is_allowed(target: str, allowed_abs: list[str]) -> bool:
    return any(target == base or target.startswith(base + os.sep) for base in allowed_abs)


def main() -> int:
    allowed_abs = load_allowed()
    data = json.load(sys.stdin)
    tool_name = data.get("tool_name", "")
    cwd = data.get("cwd") or os.getcwd()
    tool_input = data.get("tool_input") or {}

    field = PATH_FIELD_BY_TOOL.get(tool_name)
    if field is None:
        return 0
    target = tool_input.get(field)
    if not target:
        return 0

    if not os.path.isabs(target):
        target = os.path.join(cwd, target)
    target = os.path.realpath(target)

    if not is_allowed(target, allowed_abs):
        print(
            f"Blocked: {target} は許可ディレクトリ（~/src, ~/share/dotfiles 等）の外にあります",
            file=sys.stderr,
        )
        return 2
    return 0


if __name__ == "__main__":
    # PreToolUse hooks fail open on any exit code other than 2 (an uncaught
    # exception exits 1, which only shows a non-blocking error). Turn every
    # unexpected failure, e.g. a missing key in allowed-dirs.json or
    # malformed stdin, into a block instead.
    try:
        sys.exit(main())
    except Exception as e:
        print(
            f"Blocked: restrict-write-path.py の内部エラーのため拒否します ({type(e).__name__}: {e})",
            file=sys.stderr,
        )
        sys.exit(2)
