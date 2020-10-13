export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/go/bin/:/opt/apache-maven-3.5.2/bin:$PATH
###
export BASH_CONF="bashrc"

export LANG="en_US.UTF-8"

####
alias ls="ls -GFlas"
alias ll="ls -l"
alias em="emacs -nw"

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

export PS1="[\u@\[$(tput sgr0)\]\[\033[38;5;46m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;75m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]] \\$ \[$(tput sgr0)\]"

source ~/.tab.bash
source ~/.git-completion.bash
source ~/.color-tab.bash
source ~/.git-aliases.bash