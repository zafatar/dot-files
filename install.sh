#!/bin/bash
set -e

echo "Installing the dotfiles"

# Step 1. Check the environment.
DOTFILES_ENV=''
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "\nRunning on a linux-based OS...\n"
    DOTFILES_ENV='linux'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "\nRunning on a Mac OSX...\n"
    DOTFILES_ENV='mac'
else
    echo "ERROR: Tested only on Linux (Ubuntu) and Mac OSX\n"
    echo "Exiting...\n"
    exit
fi

# Step 2. Do a pre-flight check before starting the installation.
### TODO:
# - check the internet access.
# - check the rights for the files/folders.

if test ${DOTFILES_ENV}; then
    echo "Running custom installation for ${DOTFILES_ENV}"
    ./install/${DOTFILES_ENV}-install.sh
fi

# TODO: Check if oh-my-zsh installed.
if test ! -d ${HOME}/.oh-my-zsh; then
    echo -e "INFO: Installing 'oh-my-zsh'\n"
    sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# TODO: fix the first time instsallation issue.
# Issue: the installation process quits after installing OMZ.

# Replace the .zshrc with symlink from this folder.
rm -rf $HOME/.zshrc
ln -s $HOME/.dot-files/.zshrc $HOME/.zshrc

# Get these 2 favourite plugin for oh-my-zsh.
if test ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions; then
    echo -e "INFO: Installing `zsh-autosuggestions`\n"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if test ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting; then
    echo -e "INFO: Installing `zsh-syntax-highlighting`\n"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if test ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-docker-aliases; then
    echo -e "INFO: Installing `zsh-docker-aliases`\n"
    git clone https://github.com/akarzim/zsh-docker-aliases.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-docker-aliases
fi

# change the default shell to zsh
if [[ ! "$SHELL" =~ "zsh" ]]; then
    chsh -s $(which zsh)
fi

# Clean the old symlinks / files.
printf "INFO: Removing the symlinks.\n"
rm -rf $HOME/.aliases.bash
rm -rf $HOME/.aliases-git.bash
rm -rf $HOME/.completion-git.bash
rm -rf $HOME/.zzh.bash
rm -rf $HOME/.emacs
rm -rf $HOME/.emacs.d/init.el

printf "INFO: Creating the symlinks.\n"
ln -s $HOME/.dot-files/scripts/.aliases.bash $HOME/.aliases.bash
ln -s $HOME/.dot-files/scripts/.aliases-git.bash $HOME/.aliases-git.bash
ln -s $HOME/.dot-files/scripts/.completion-git.bash $HOME/.completion-git.bash
ln -s $HOME/.dot-files/scripts/.zzh.bash $HOME/.zzh.bash

# copy the .emacs files - symlink in git not good for emacs.
cp $HOME/.dot-files/editors/.emacs $HOME/.emacs
cp $HOME/.dot-files/editors/emacs/init.el $HOME/.emacs.d/init.el

printf "INFO: Refreshing the shell.\n"

# make sure that we are on zsh
zsh
source $HOME/.zshrc

echo -e "\e[0;32mDone!\e[0m"
