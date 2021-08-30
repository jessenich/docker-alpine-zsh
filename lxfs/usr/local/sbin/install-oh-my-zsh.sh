#!/usr/bin/env bash

export ZSH="/usr/local/share/zsh/oh-my-zsh";
USER="$(cat /etc/passwd | grep ':1000:1000:' | awk -F':' '{ print $1 }')";
if [ -n "${USER}" ]; then
    chsh -s /bin/zsh "${USER}";
    cp /etc/zsh/zshrc_template "/home/${USER}/.zshrc";
else
    echo "No non-root accounts found to zsh-ify.";
fi

/bin/bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if [ -d /root/.oh-my-zsh ]; then
    mv /root/.oh-my-zsh "${ZSH}";
fi

if [ -f /root/.zshrc.pre-oh-my-zsh ]; then
    mv /root/.zshrc.pre-oh-my-zsh /root/.zshrc
fi

cp /root/.zshrc "/home/$USER/.zshrc"

chsh -s /bin/zsh "$USER"
chsh -s /bin/zsh root
