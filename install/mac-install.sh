#!/bin/sh

# install Homebrew if it's not installed
if test ! $(which brew); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "Homebrew found. Version: \n\n$(brew --version)"
fi

# TODO: Add casks.

if test ! $(which zsh); then
    echo -e "INFO: Installing `zsh`\n"
    brew install zsh
fi
