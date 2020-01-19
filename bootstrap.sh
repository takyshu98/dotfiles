#!/usr/bin/env bash

set -eu

# install homebrew
if ! command -v brew >/dev/null 2>&1; then
  # https://brew.sh/
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo
fi
brew bundle
echo

SHRPATH=$HOME/share
mkdir -p "$SHRPATH"
mkdir -p ~/bin
mkdir -p ~/src

DOTPATH=$SHRPATH/dotfiles

if [ ! -d "$DOTPATH" ]; then
  git clone https://github.com/takyshu98/dotfiles.git "$DOTPATH"
else
  echo "$DOTPATH already downloaded. Updating..."
  cd "$DOTPATH"
  git stash
  git checkout master
  git pull origin master
  echo
fi

cd "$DOTPATH"

# TODO
# Mac basic settings
# scripts/configure.sh
# echo

scripts/deploy.sh
echo

scripts/initialize.sh
echo

echo "Bootstrapping DONE!"
