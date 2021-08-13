# shellcheck shell=bash
# shellcheck source-path=SCRIPTDIR
# shellcheck enable=quote-safe-variables
# shellcheck enable=check-unassigned-uppercase
# shellcheck disable=SC2034,SC2016,SC1091

if [ -d "$HOME/bin" ]; then
  export PATH=$HOME/bin:/usr/local/bin:$PATH;
fi

export ZSH="/usr/share/zsh/.oh-my-zsh"
export ZSH_THEME="agnoster"
export HYPHEN_INSENSITIVE="true"
export DISABLE_AUTO_UPDATE="true"
export ENABLE_CORRECTION="true"
export COMPLETION_WAITING_DOTS="true"
export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8
export EDITOR='nano'
export HIST_STAMPS="yyyy-mm-dd"

source "$ZSH/oh-my-zsh.sh"

# ZSH_CUSTOM=/path/to/new-custom-folder
plugins=(

)

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if [ -f "${HOME}/.zsh_aliases" ]; then
    . "${HOME}/.zsh_aliases"
fi

edit-zshconfig() { "$EDITOR ~/.zshrc"; }
edit-ohmyzsh() { "$EDITOR $ZSH/.oh-my-zsh/oh-my-zsh"; }
src-ohmyzsh() { "source /usr/share/zsh/zshrc.ohmyzsh.sh"; }
src-zshrc() { "source ~/.zshrc"; }
