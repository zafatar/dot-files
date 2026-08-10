#!/bin/sh
set -e

# Update the libraries
sudo apt-get update

# Install a package only if this release actually offers it. Several of the
# modern CLI tools below are absent on older Debian/Ubuntu, and one missing
# package should not abort the whole run.
apt_install() {
    for pkg in "$@"; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            sudo apt-get -y install "$pkg"
        else
            printf "WARN: not available on this release, skipping: %s\n" "$pkg"
        fi
    done
}

# Install the first candidate that exists, for packages that were renamed
# between releases.
apt_install_first() {
    for pkg in "$@"; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            sudo apt-get -y install "$pkg"
            return 0
        fi
    done
    printf "WARN: none of these are available, skipping: %s\n" "$*"
}

if ! command -v zsh >/dev/null 2>&1; then
    printf "INFO: Installing zsh\n"
    sudo apt-get -y install zsh
fi

# Resolve the real zsh path; apt installs to /usr/bin/zsh, not /usr/local/bin.
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
apt_install emacs htop git curl wget rsync nmap tree

# Modern CLI tools, kept in step with install/mac-install.sh.
# Debian names differ from Homebrew: fd is packaged as fd-find (binary fdfind)
# and bat installs its binary as batcat. scripts/.aliases.sh aliases both back
# to their upstream names.
# eza is only packaged from Debian 13 / Ubuntu 24.04 onward; older releases
# will skip it with a warning.
apt_install fzf bat fd-find duf fastfetch eza

# telnet was split out as inetutils-telnet in newer Debian releases.
apt_install_first telnet inetutils-telnet

# Docker
apt_install docker.io docker-compose

# groupadd fails if the group already exists, which is the normal case after
# installing docker.io, so only create it when missing.
getent group docker >/dev/null 2>&1 || sudo groupadd docker
sudo usermod -aG docker "$USER"
