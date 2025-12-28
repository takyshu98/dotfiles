#
# @file ~/.config/zsh/.zprofile
# @brief initial setup file for only non interactive zsh
#        This file is read after .zshenv file is read.
#

# Set brew installed command paths
# Defining in zshenv instead of zprofile, there will be a problem with the loading order
# ref: https://github.com/orgs/Homebrew/discussions/1127
ARCH_TYPE="$(arch)"
if [ "${ARCH_TYPE}" = "i386" ]; then
  eval "$(/usr/local/bin/brew shellenv)"    # for Intel
elif [ "${ARCH_TYPE}" = "arm64" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)" # for Apple silicon
fi

# Add shims to path for default shell
# ref:https://mise.jdx.dev/ide-integration.html#adding-shims-to-path-default-shell
eval "$(mise activate --shims)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
