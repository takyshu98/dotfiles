#!/usr/bin/env bash

set -e

eval "$(anyenv init -)"

if [ ! -d "$HOME/.config/anyenv/anyenv-install" ]; then
  anyenv install --init
fi

anyenv install jenv
anyenv install nodenv
anyenv install pyenv
