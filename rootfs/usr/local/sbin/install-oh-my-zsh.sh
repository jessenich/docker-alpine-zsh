#!/usr/bin/env bash

export ZSH="/home/.common/zsh/oh-my-zsh";
export USER= ;
USER="$(cat /etc/passwd | grep ':1000:1000:' | awk -F':' '{ print $1 }')";

export REPO="jessenich/ohmyzsh";
export BRANCH="jesse/main";

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --skip-chsh --keep-zshrc

# DOuble check it didnt drop it in roots homeholder
if [ -d /root/.oh-my-zsh ]; then mv /root/.oh-my-zsh "$(dirname "$ZSH")"; fi
if [ -f /root/.zshrc.pre-oh-my-zsh ]; then rm -f /root/.zshrc.pre-oh-my-zsh; fi
if [ -f /root/.zshrc ]; then rm -f /root/.zshrc; fi

cp -f /etc/zsh/zshrc_template /root/.zshrc
cp -f /etc/zsh/zshrc_template "/home/$USER/.zshrc"

chsh -s /bin/zsh "$USER"
chsh -s /bin/zsh root

echo "$USER";
exit 0;