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
  if [[ "${file_name}" =~ ^(\.DS_Store|\.config|\.git|\.github|\.gitignore)$ ]]; then
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

# Make directories with reference to Filesystem Hierarchy Standard
mkdir -pv "${HOME}/bin" # for self manage commands
mkdir -pv "${HOME}/src" # for code repositories
mkdir -pv "${HOME}/var/"{archive,recent,tmp,screenshot} # for temporary workspace


# find "${DOTHOME}/bin/" -type f ! -name '.DS_Store' -perm 0755 -exec ln -fvns {} "${HOME}/bin/" \;

## shellcheck disable=SC2174
## https://github.com/koalaman/shellcheck/wiki/SC2174
# mkdir -m 700 -p "${HOME}/.ssh"