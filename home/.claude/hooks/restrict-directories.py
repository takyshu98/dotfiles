#!/usr/bin/env python3
"""PreToolUse hook: block file tools outside the paths listed in
~/.claude/allowed-dirs.json.

Two checks, both against the same allowlist:
1. The session's cwd must itself be inside the allowlist. This blocks every
   matched tool, including Bash, whenever Claude Code was launched outside
   an approved directory.
2. For file tools (Read/Write/Edit/MultiEdit/NotebookEdit/Grep/Glob), the
   tool's actual target path is resolved and checked too. Unlike
   permissions.blockReadsOutsideWorkingDirectories, this does not trust the
   launch cwd for this check either: it looks at the resolved target
   regardless of where Claude Code was started.

Bash is exempt from the target check: parsing an arbitrary shell command
string for the paths it touches isn't reliable (quoting, pipes, variable
expansion), so Bash's actual filesystem access is left to sandbox.filesystem
instead. This hook only gates whether Bash may run at all via check 1.

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

    cwd_real = os.path.realpath(cwd)
    if not is_allowed(cwd_real):
        print(
            f"Blocked: 起動ディレクトリ {cwd_real} は許可ディレクトリ（~/src, ~/share/dotfiles 等）の外にあります",
            file=sys.stderr,
        )
        return 2

    if tool_name == "Bash":
        # コマンド文字列のパース（引用符・パイプ・変数展開）は信頼できないため、
        # ファイルアクセスの可否はsandbox.filesystemに委ねる。ここではcwdのみ判定する。
        return 0

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
