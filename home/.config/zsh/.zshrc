#
# @file ~/.config/zsh/.zshrc
# @brief initial setup file for only interactive zsh
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

# Activate plugins
eval "$(sheldon source)"

# Set completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # Enable completion without distinguishing uppercase or lowercase. except for input uppercase

# Set emacs key bindings
bindkey -e

# Set alias
alias ls='ls -FG'
alias awk='gawk'
alias grep='ggrep'
alias sed='gsed'

# Set history options
export HISTFILE="${XDG_STATE_HOME}/.zsh_history"
export HISTSIZE=3000
export SAVEHIST=3000

setopt hist_expire_dups_first # Delete the oldest duplicate event first when truncating the history
setopt hist_ignore_all_dups   # Delete old history if history is duplicated
setopt hist_ignore_dups       # Don't save to history if it overlaps with the previous event
setopt hist_save_no_dups      # Discard old commands that overlap with new commands

function select-history() {
  BUFFER="$(history -n -r 1 | fzf --exact --no-sort --reverse --border-label="history" --no-scrollbar --prompt="Search > " --color='bg+:-1' --query="$LBUFFER")"
  CURSOR="${#BUFFER}"
}
zle -N select-history
bindkey '^r' select-history

# Set tool options
export FZF_DEFAULT_OPTS='--height 40% --reverse --border --no-scrollbar --color='bg+:-1''

# Activate runtime
export PIPENV_VENV_IN_PROJECT=true  # create virtual enviroment in each project
eval "$(mise activate zsh)"