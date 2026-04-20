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

alias ff="fastfetch"
alias ad="cd ~/Works/autodesk"
alias personal="cd ~/Works/personal"
alias pems="cd ~/Works/autodesk/vault/pems"
alias update="omz update && brew outdated && brew upgrade"

alias pycache_clean="find . | grep -E \"(/__pycache__$|\.pyc$|\.pyo$)\" | xargs rm -rf"

alias gpg_test="echo \"test\" | gpg --clearsign"

function wifipwd {
    wifiname=$1
    security find-generic-password -ga $wifiname | grep -e 'password:'
}

alias localjenkinsrestart='docker stop jenkins;docker rm jenkins;docker run --name jenkins -i -d -p 8787:8080 -p 50000:50000 -v $HOME/Works/autodesk/sandbox/jenkins/jenkins_home:/var/jenkins_home:rw local_jenkins'

alias autodesk_ips="curl -s -XGET https://ipsafelist.autodesk.com/ipsafelist.json | jq -r '.PublicIp | sort_by(.Geo, .Country) | .[] | select ( .Geo == \"EMEA\" and (.Country == \"Germany\" or .Country == \"Ireland\" )) | [.Network, .Geo, .Country, .NetworkType] | @tsv' | column -t"

alias run_jupyter="docker run -it --rm -p 9999:9999 -e JUPYTER_PORT=9999 -v $PWD:/home/jovyan --name jupyter jupyter/base-notebook"

# TOFU
alias tw="tofu workspace"
alias twl="tofu workspace list"
alias twn="tofu workspace new"
alias tws="tofu workspace select"
alias tf="tofu"

# AWS
alias al="aws-login"

# Argo kubectl
alias argo-admin="kops export kubecfg --name cumin.blank.autodesk.com --state s3://cumin-kops-state --admin --kubeconfig $HOME/.kube/config.kops-cumin.blank.autodesk.com && export KUBECONFIG=$HOME/.kube/config.kops-cumin.blank.autodesk.com && kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"

# Git Aliases.
source $HOME/.aliases-git.sh
