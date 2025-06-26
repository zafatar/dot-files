#!/bin/sh

# Update the libraries
yay -Syu

if test ! $(which zsh); then
    echo -e "INFO: Installing `zsh`\n"
    yay -S zsh

    # Add it to the available shell list.
    sudo -s 'echo /usr/local/bin/zsh >> /etc/shells'

    # Change the Shell
    chsh -s /usr/local/bin/zsh
fi

# Misc. Installations.
yay -S emacs
yay -S htop
yay -S git

# Docker
yay -S docker
yay -S docker-compose

sudo groupadd docker
sudo usermod -aG docker $USER