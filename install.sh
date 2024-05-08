#!/bin/bash
set -e

printf "Installing the .dot-files"

# Step 1. Check the environment.
DOTFILES_ENV=''
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    printf "\nRunning on a linux-based OS 🐧 ...\n"
    DOTFILES_ENV='linux'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    printf "\nRunning on a Mac OSX  ...\n"
    DOTFILES_ENV='mac'
else
    printf "ERROR: Tested only on Linux (Ubuntu) and Mac OSX\n"
    printf "Exiting...\n"
    exit
fi

# Step 2. Do a pre-flight check before starting the installation.
### TODO:
# - check the internet access.
# - check the rights for the files/folders.

if test ${DOTFILES_ENV}; then
    printf "\nRunning custom installation for ${DOTFILES_ENV}...\n"
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

# install zsh-completions
if test ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions; then
    echo -e "INFO: Installing `zsh-completions`\n"
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
fi

if test ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-docker-aliases; then
    echo -e "INFO: Installing `zsh-docker-aliases`\n"
    git clone https://github.com/akarzim/zsh-docker-aliases.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-docker-aliases
fi

# change the default shell to zsh
if [[ ! "$SHELL" =~ "zsh" ]]; then
    chsh -s $(which zsh)
fi

function refresh-symlinks() {
    # Clean the old symlinks / files.
    printf "INFO: Removing the symlinks.\n"

    rm -rf $HOME/.aliases.sh
    rm -rf $HOME/.aliases-git.sh
    rm -rf $HOME/.color-tab.iterm.sh
    rm -rf $HOME/.completion-git.sh
    rm -rf $HOME/.zzh.sh

    rm -rf $HOME/.config/emacs/init.el
    rm -rf $HOME/.config/emacs/early-init.el
    rm -rf $HOME/.config/emacs/config.org

    printf "INFO: Creating the symlinks.\n"
    ln -s $HOME/.dot-files/scripts/.aliases.sh $HOME/.aliases.sh
    ln -s $HOME/.dot-files/scripts/.aliases-git.sh $HOME/.aliases-git.sh
    ln -s $HOME/.dot-files/scripts/.color-tab.iterm.sh $HOME/.color-tab.iterm.sh
    ln -s $HOME/.dot-files/scripts/.completion-git.sh $HOME/.completion-git.sh
    ln -s $HOME/.dot-files/scripts/.zzh.sh $HOME/.zzh.sh

    # Emacs
    ln -s $HOME/.dot-files/.config/emacs/init.el $HOME/.config/emacs/init.el
    ln -s $HOME/.dot-files/.config/emacs/early-init.el $HOME/.config/emacs/early-init.el
    ln -s $HOME/.dot-files/.config/emacs/config.org $HOME/.config/emacs/config.org
}

refresh-symlinks

printf "\n ✅ \e[0;32mDone!\e[0m \e[0;32mPlease restart the terminal.\e[0m\n\n"