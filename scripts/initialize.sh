#!/usr/bin/env bash

set -e

eval "$(anyenv init -)"

if [ ! -d "$ANYENV_DEFINITION_ROOT" ]; then
  anyenv install --init
fi

anyenv install jenv
anyenv install nodenv
anyenv install pyenv
