#!/usr/bin/env bash

set -eu

# anyenv
eval "$(anyenv init -)"
if [ ! -d "$HOME/.config/anyenv/anyenv-install" ]; then
  anyenv install --init
fi

ANYPATH="$HOME/.anyenv"

# jenv
if [ ! -d "$ANYPATH/envs/jenv" ]; then
  anyenv install jenv
fi

# nodenv
if [ ! -d "$ANYPATH/envs/nodenv" ]; then
  anyenv install nodenv
fi

# pyenv
if [ ! -d "$ANYPATH/envs/pyenv" ]; then
  anyenv install pyenv
fi

# anyenv-update
if [ ! -d "$ANYPATH/plugins" ]; then
  mkdir -p "$ANYPATH/plugins"
  git clone https://github.com/znz/anyenv-update.git "$ANYPATH/plugins/anyenv-update"
fi
anyenv update
