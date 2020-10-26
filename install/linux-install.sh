#!/bin/sh

# Update the libraries
sudo apt-get update

if test ! $(which zsh); then
    echo -e "INFO: Installing `zsh`\n"
    sudo apt-get install zsh
fi
