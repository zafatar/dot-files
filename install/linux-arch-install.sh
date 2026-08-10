#!/bin/sh
set -e

# Update the libraries
yay -Syu --noconfirm

# --needed skips packages that are already up to date.
pkg_install() {
    yay -S --needed --noconfirm "$@"
}

if ! command -v zsh >/dev/null 2>&1; then
    printf "INFO: Installing zsh\n"
    pkg_install zsh
fi

# Resolve the real zsh path; pacman installs to /usr/bin/zsh, not /usr/local/bin.
ZSH_PATH="$(command -v zsh)"

# Add it to the available shell list.
if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

# Change the Shell
if [ "$SHELL" != "$ZSH_PATH" ]; then
    chsh -s "$ZSH_PATH"
fi

# Editor and general system tools.
pkg_install emacs htop git curl wget rsync nmap tree

# Modern CLI tools, kept in step with install/mac-install.sh.
# Arch ships these under their upstream names, so no aliasing is needed.
pkg_install fzf bat fd duf fastfetch eza

# telnet lives in the inetutils package on Arch.
pkg_install inetutils

# Docker
pkg_install docker docker-compose

# groupadd fails if the group already exists, which is the normal case after
# installing docker, so only create it when missing.
getent group docker >/dev/null 2>&1 || sudo groupadd docker
sudo usermod -aG docker "$USER"
