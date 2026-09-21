#!/bin/bash

set -eu

readonly DOTHOME="${HOME}/share/dotfiles/home"

if [ ! -e "${DOTHOME}" ]; then
  echo "Error: Directory does not exist: ${DOTHOME}"
  exit 1
fi

# Make symbolic links from ~/.* to ~/share/dotfiles/home/.*
for file_path in "${DOTHOME}"/.??*; do
  file_name="$(basename "${file_path}")"
  if [[ "${file_name}" =~ ^(\.DS_Store|\.config|\.claude|\.git|\.github|\.gitignore)$ ]]; then
    continue
  fi
  ln -fvns "${DOTHOME}/${file_name}" "${HOME}/${file_name}"
done

# Make symbolic links based on XDG Base Directory specification
: "${XDG_CONFIG_HOME:=${HOME}/.config}"
: "${XDG_CACHE_HOME:=${HOME}/.cache}"
: "${XDG_DATA_HOME:=${HOME}/.local/share}"
: "${XDG_STATE_HOME:=${HOME}/.local/state}"

mkdir -pv "${XDG_CONFIG_HOME}"
mkdir -pv "${XDG_CACHE_HOME}"
mkdir -pv "${XDG_DATA_HOME}"
mkdir -pv "${XDG_STATE_HOME}"

find "${DOTHOME}/.config" -maxdepth 1 ! -name '.config' ! -name '.DS_Store' -exec ln -fvns {} "${XDG_CONFIG_HOME}" \;

# Link only managed files inside ~/.claude, since the rest of the directory
# is live application state (history, sessions, cache) that must stay a real
# directory, not a symlinked one.
mkdir -pv "${HOME}/.claude"
ln -fvns "${DOTHOME}/.claude/settings.json" "${HOME}/.claude/settings.json"
ln -fvns "${DOTHOME}/.claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
ln -fvns "${DOTHOME}/.claude/allowed-dirs.json" "${HOME}/.claude/allowed-dirs.json"

# Same idea for ~/.claude/skills: only the skills managed in this repo are
# symlinked in, one directory at a time, so unmanaged skills installed
# outside this repo are left untouched.
mkdir -pv "${HOME}/.claude/skills"
find "${DOTHOME}/.claude/skills" -mindepth 1 -maxdepth 1 -type d -exec ln -fvns {} "${HOME}/.claude/skills" \;

# Same idea for ~/.claude/hooks: only hooks managed in this repo are symlinked
# in, one file at a time, so tool-managed hooks (e.g. Herdr's
# herdr-agent-state.sh) that live directly in the real directory are left
# untouched.
mkdir -pv "${HOME}/.claude/hooks"
ln -fvns "${DOTHOME}/.claude/hooks/restrict-directories.py" "${HOME}/.claude/hooks/restrict-directories.py"

# permissions.additionalDirectories and sandbox.filesystem.allowRead/allowWrite
# in settings.json are generated from allowed-dirs.json so the allowlist has a
# single source of truth. Re-run this script after editing allowed-dirs.json
# to regenerate settings.json; review with `git diff` before committing.
DIRS_FILE="${DOTHOME}/.claude/allowed-dirs.json"
SETTINGS_FILE="${DOTHOME}/.claude/settings.json"
jq --slurpfile dirs "${DIRS_FILE}" '
  .permissions.additionalDirectories = $dirs[0]
  | .sandbox.filesystem.allowRead = $dirs[0]
  | .sandbox.filesystem.allowWrite = $dirs[0]
' "${SETTINGS_FILE}" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "${SETTINGS_FILE}"

# Make directories with reference to Filesystem Hierarchy Standard
mkdir -pv "${HOME}/bin" # for self manage commands
mkdir -pv "${HOME}/src" # for code repositories
mkdir -pv "${HOME}/var/"{archive,recent,tmp,screenshot} # for temporary workspace


# find "${DOTHOME}/bin/" -type f ! -name '.DS_Store' -perm 0755 -exec ln -fvns {} "${HOME}/bin/" \;

## shellcheck disable=SC2174
## https://github.com/koalaman/shellcheck/wiki/SC2174
# mkdir -m 700 -p "${HOME}/.ssh"