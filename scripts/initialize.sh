#!/usr/bin/env bash

set -e

eval "$(anyenv init -)"

if [ ! -d "$HOME/.config/anyenv/anyenv-install" ]; then
  anyenv install --init
fi

if [ ! -d "$HOME/.anyenv/envs/jenv" ]; then
  anyenv install jenv
fi

if [ ! -d "$HOME/.anyenv/envs/nodenv" ]; then
  anyenv install nodenv
fi

if [ ! -d "$HOME/.anyenv/envs/pyenv" ]; then
  anyenv install pyenv
fi

if [ ! -d "$HOME/.anyenv/plugins" ]; then
  mkdir -p "$HOME/.anyenv/plugins"
  git clone https://github.com/znz/anyenv-update.git "$HOME/.anyenv/plugins/anyenv-update"
fi

anyenv update
