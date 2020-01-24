#!/usr/bin/env bash

set -eu

# make directories
if [ ! -d ~/bin ]; then mkdir -p ~/bin; fi
if [ ! -d ~/share ]; then mkdir -p ~/share; fi
if [ ! -d ~/src ]; then mkdir -p ~/src; fi
if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh
  touch ~/.ssh/config
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/*
fi

# install homebrew and git in it
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
