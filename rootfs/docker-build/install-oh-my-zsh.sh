#!/usr/bin/env bash

USER="$(cat /etc/passwd | grep ':1000:1000:' | awk -F':' '{ print $1 }')";
export USER;

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Double check it didnt drop it in roots homeholder
if [ -d /root/.oh-my-zsh ]; then mv /root/.oh-my-zsh /home/$USER/.oh-my-zsh; fi
if [ -f /root/.zshrc.pre-oh-my-zsh ]; then rm -f /root/.zshrc.pre-oh-my-zsh; fi
if [ -f /home/$USER/.zshrc.pre-oh-my-zsh ]; then rm -f /home/$USER/.zshrc.pre-oh-my-zsh; fi

chsh -s "$(command -v zsh)" "$USER"
chsh -s "$(command -v zsh)" root

echo "$USER";
exit 0;
