# All the aliases calls.

alias resetshell="source $HOME/.zshrc"

alias cpssh="pbcopy | cat $HOME/.ssh/id_rsa.pub"

# Misc and fun.
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias c="clear"
alias f="fortune"

# Docker Aliases.
alias dim="docker image"
alias dco="docker container"

# Git Aliases.
source $HOME/.aliases-git.bash
