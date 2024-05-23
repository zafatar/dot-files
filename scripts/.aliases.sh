# All the aliases calls.

alias resetshell="source $HOME/.zshrc"

alias cpssh="cat $HOME/.ssh/id_rsa.pub | pbcopy"

# Misc and fun.
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias c="clear"
alias f="fortune"

# Docker Aliases.
alias dc="docker container"
alias dv="docker volume"
alias di="docker image"

alias dco="docker compose"

# Screen
alias sls="screen -ls"
alias srd="screen -r -d"
alias scr="screen -S"

# Misc.
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # echo -e "\nCreating alisase for linux-based OS...\n"
    alias ls='ls -la --color --quoting-style=literal'

    alias lsdisk="lsblk -o UUID,NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # echo -e "\nCreating alisase for linux-based OS...\n"
    alias ls='ls -laG'

    alias lsdisk="diskutil list"
fi

alias ll="ls -la"

alias emacs="emacs -nw"

# AWS
alias aws-login-dev=". aws-dev-login.sh"
alias aws-running-instances="aws ec2 describe-instances | jq '.Reservations[].Instances[] | select (.State.Code == 16) | [.InstanceId, .InstanceType, .State.Name, .PrivateIpAddress, (.Tags[]|select(.Key==\"Name\")|.Value)]'"

alias aws-all-instances="aws ec2 describe-instances | jq '.Reservations[].Instances[] | [.InstanceId, .InstanceType, .State.Name, .PrivateIpAddress, (.Tags[]|select(.Key==\"Name\")|.Value)]'"

alias ff="fastfetch"

alias ad="cd ~/Works/autodesk"
alias personal="cd ~/Works/personal"
alias python="python3"
alias update="omz update && brew outdated && brew upgrade"

function wifipwd {
    wifiname=$1
    security find-generic-password -ga $wifiname | grep -e 'password:'
}

# Git Aliases.
source $HOME/.aliases-git.sh
