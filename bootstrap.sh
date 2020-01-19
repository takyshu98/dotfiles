#!/usr/bin/env bash

set -eu

mkdir -p ~/bin
mkdir -p ~/share
mkdir -p ~/src

# install homebrew
# to install git command before use
if ! command -v brew >/dev/null 2>&1; then
  # https://brew.sh/
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo
fi

DOTPATH="$HOME/share/dotfiles"

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

brew bundle
echo

# TODO
# Mac basic settings
# scripts/configure.sh
# echo

scripts/deploy.sh
echo

scripts/initialize.sh
echo

echo "Bootstrapping DONE!"
