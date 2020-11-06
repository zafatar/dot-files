#!/bin/sh

# Update the libraries
sudo apt-get update

if test ! $(which zsh); then
    echo -e "INFO: Installing `zsh`\n"
    sudo apt-get install zsh
fi

# Misc. Installations.
sudo apt-get -y install emacs
sudo apt-get -y install htop
sudo apt-get -y install git

# Docker
sudo apt-get -y install docker.io
sudo apt-get -y install docker-compose

sudo groupadd docker
sudo usermod -aG docker $USER

# what else...
