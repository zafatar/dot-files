#!/bin/sh
set -e

# install Homebrew if it's not installed
echo "\n============================================="
printf "Checking if Homebrew is installed...\n"

if test ! $(which brew); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    printf "Homebrew found. Version: \n$(brew --version)\n"
fi

echo "\n============================================="
printf "Checking if zsh is installed...\n"

if test ! $(which zsh); then
    printf "INFO: Installing `zsh`\n"
    brew install zsh

    sudo -s 'echo /usr/local/bin/zsh >> /etc/shells'

    chsh -s /usr/local/bin/zsh
else
    printf "ZSH found. Version: \n$(zsh --version)\n"
fi

echo "\n============================================="
printf "Installing applications...\n\n"

brew install git htop fastfetch rsync telnet nmap tree

# Add more explanations here.
brew install fzf bat exa fd

# ...

echo "\n============================================="