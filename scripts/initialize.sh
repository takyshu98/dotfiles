#!/usr/bin/env bash

set -e

eval "$(anyenv init -)"
anyenv install --init
anyenv install jenv
anyenv install nodenv
anyenv install pyenv
