#
# @file ~/.zshrc
# @brief initial setup file for only interactive zsh
#        This file is read after .zshenv file is read.
#

# initialize zplug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# add plugins by zplug
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "mafredri/zsh-async"
zplug "sindresorhus/pure"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
# zplug "zsh-users/zsh-history-substring-search" # seems to not working in any work around
zplug "zsh-users/zsh-completions"
zplug "chrissicool/zsh-256color"
zplug "b4b4r07/enhancd", use:init.sh
zplug "plugins/git", from:oh-my-zsh

# zplug check returns true if all packages are installed
# Therefore, when it returns false, run zplug install
if ! zplug check; then
    zplug install
fi

# source plugins and add commands to the PATH
zplug load #--verbose

# // compinit is activate in zplug //

# set zsh completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# set zsh options
setopt hist_ignore_dups
setopt no_clobber
unsetopt PROMPT_SP # work around for Hyper first line percent sign issue#2144

# set zsh emacs key bindings
bindkey -e

# set alias
alias ls='ls -FG'

# set shell variables
# PROMPT=$'[%~]\n%m{%n}%% '
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# set shell functions
# work around for Hyper plugin hyper-tab-icons can't reflect tab titles issue#1188
# Override auto-title when static titles are desired ($ title My new title)
title() { export TITLE_OVERRIDDEN=1; echo -en "\e]0;$*\a" }
# Turn off static titles ($ autotitle)
autotitle() { export TITLE_OVERRIDDEN=0 }; autotitle
# Condition checking if title is overridden
overridden() { [[ $TITLE_OVERRIDDEN == 1 ]]; }
# Echo asterisk if git state is dirty
gitDirty() { [[ $(git status 2> /dev/null | grep -o '\w\+' | tail -n1) != ("clean"|"") ]] && echo "*" }

# Show cwd when shell prompts for input.
tabtitle_precmd() {
    if overridden; then return; fi
    pwd=$(pwd) # Store full path as variable
    cwd=${pwd##*/} # Extract current working dir only
    print -Pn "\e]0;$cwd$(gitDirty)\a" # Replace with $pwd to show full path
}
[[ -z $precmd_functions ]] && precmd_functions=()
precmd_functions=($precmd_functions tabtitle_precmd)

# Prepend command (w/o arguments) to cwd while waiting for command to complete.
tabtitle_preexec() {
    if overridden; then return; fi
    printf "\033]0;%s\a" "${1%% *} | $cwd$(gitDirty)" # Omit construct from $1 to show args
}
[[ -z $preexec_functions ]] && preexec_functions=()
preexec_functions=($preexec_functions tabtitle_preexec)

# initialize anyenv
eval "$(anyenv init -)"

# initialize pipenv
# create virtual enviroment in each project
export PIPENV_VENV_IN_PROJECT=true
