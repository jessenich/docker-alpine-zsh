# Set up the prompt

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

if [ -f "/usr/share/zsh/zsh_env.sh" ]; then
    . "/usr/share/zsh/zsh_env.sh";
fi

if [ -f "${HOME}/.zsh_aliases" ]; then
    . "${HOME}/.zsh_aliases";
fi

if [ -f "/usr/share/zsh/zsh_env.sh" ]; then
    . "/usr/share/zsh/zsh_env.sh";
fi

# Import oh-my-zsh
if [ -f "/usr/share/zsh/zshrc.ohmyzsh.sh" ]; then
    . "/usr/share/zsh/zshrc.ohmyzsh.sh";
fi

if [ -f "/usr/share/zsh/zsh_aliases.sh" ]; then
    . "/usr/share/zsh/zsh_aliases.sh";
fi
