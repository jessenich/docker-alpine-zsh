#!/usrbin/env zsh

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

#shellcheck shell=bash


# shellcheck shell=bash
# shellcheck source-path=SCRIPTDIR
# shellcheck enable=quote-safe-variables
# shellcheck enable=check-unassigned-uppercase
# shellcheck disable=SC2034,SC2016,SC1091

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory
bindkey -e

export HISTSIZE=100000
export SAVEHIST=1000000
export HISTFILE="${HOME}/.zsh_history"

autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
if [ -f "/home/.common/zsh/zsh_env.zsh" ]; then
    source "/home/.common/zsh/zsh_env.zsh";
fi

if [ -f "/home/.common/zsh/zsh_aliases.zsh" ]; then
    source "/home/.common/zsh/zsh_aliases.zsh";
fi

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh";
fi

edit-zshconfig() { "$EDITOR ~/.zshrc"; }
edit-ohmyzsh() { "$EDITOR $ZSH/.oh-my-zsh/oh-my-zsh"; }
src-ohmyzsh() { "source /home/.common/zsh/zshrc.ohmyzsh.sh"; }
src-zshrc() { "source ~/.zshrc"; }