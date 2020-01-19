#
# @file ~/.zshenv
# @brief initial setup file for both interactive and noninteractive zsh
#

# Set locale
export LANG=ja_JP.UTF-8

# Set path
export PATH="/usr/local/bin:/usr/sbin:${HOME}/bin:${PATH}"

# Set xdg
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

# Set zdotdir
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"