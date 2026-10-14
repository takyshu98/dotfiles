#!/usr/bin/env python3
"""PreToolUse hook: block every tool when the session's cwd is outside the
paths listed in ~/.claude/allowed-dirs.json.

Registered with matcher "*", so it gates all tools (built-in, MCP, ...)
whenever Claude Code was launched outside an approved directory. It does not
look at what a tool touches; see restrict-write-path.py for that.

Uses "tools" (directories) plus "files" (single files, since
permissions.additionalDirectories rejects non-directory entries) from
allowed-dirs.json. "sandboxExtra" (tool caches/state that only sandboxed Bash
needs) is deliberately not checked here.
"""
import json
import os
import sys

ALLOWED_DIRS_FILE = os.path.expanduser("~/.claude/allowed-dirs.json")


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
    cwd_real = os.path.realpath(data.get("cwd") or os.getcwd())

    if not is_allowed(cwd_real, allowed_abs):
        print(
            f"Blocked: 起動ディレクトリ {cwd_real} は許可ディレクトリ（~/src, ~/share/dotfiles 等）の外にあります",
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
            f"Blocked: restrict-cwd.py の内部エラーのため拒否します ({type(e).__name__}: {e})",
            file=sys.stderr,
        )
        sys.exit(2)
