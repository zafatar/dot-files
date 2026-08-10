#!/bin/sh
set -e

# install Homebrew if it's not installed
echo "\n============================================="
printf "Checking if Homebrew is installed...\n"

if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    printf "Homebrew found. Version: \n$(brew --version)\n"
fi

echo "\n============================================="
printf "Checking if zsh is installed...\n"

if ! command -v zsh >/dev/null 2>&1; then
    printf "INFO: Installing zsh\n"
    brew install zsh
fi

# Resolve the real zsh path instead of assuming /usr/local/bin/zsh, which is
# wrong on Apple Silicon (/opt/homebrew/bin/zsh) and when using the system zsh.
ZSH_PATH="$(command -v zsh)"
printf "ZSH found at %s. Version: \n%s\n" "$ZSH_PATH" "$(zsh --version)"

if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    printf "INFO: Adding %s to /etc/shells\n" "$ZSH_PATH"
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

if [ "$SHELL" != "$ZSH_PATH" ]; then
    chsh -s "$ZSH_PATH"
fi

echo "\n============================================="
printf "Installing applications...\n\n"

brew install git htop fastfetch rsync telnet nmap tree

# Add more explanations here.
brew install fzf bat eza fd duf

# ...

echo "\n============================================="