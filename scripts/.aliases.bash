# All the aliases calls.

alias resetshell="source $HOME/.zshrc"

alias cpssh="cat $HOME/.ssh/id_rsa.pub | pbcopy"

# Misc and fun.
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias c="clear"
alias f="fortune"

# Docker Aliases.
alias dim="docker image"
alias dco="docker container"

# Screen
alias sls="screen -ls"
alias srd="screen -r -d"
alias scr="screen -S"

# List the disks - Only for Linux-*
alias lsdisk="lsblk -o UUID,NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL"

# Misc.
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # echo -e "\nCreating alisase for linux-based OS...\n"
    alias ls='ls -la --color --quoting-style=literal'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # echo -e "\nCreating alisase for linux-based OS...\n"
    alias ls='ls -laG'
fi

alias ll="ls -l"
alias emacs="emacs -nw"

# TODO: Check if they exist
alias mysql=/usr/local/bin/mysql
alias mysqladmin=/usr/local/bin/mysqladmin

# Git Aliases.
source $HOME/.aliases-git.bash
