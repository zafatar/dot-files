# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"
# ZSH_THEME="powerlevel10k/powerlevel10k"

BULLETTRAIN_TIME_BG="blue"
BULLETTRAIN_TIME_FG="white"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    aws
    macos
    docker
    history
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-docker-aliases
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/go/bin/:/opt/apache-maven-3.5.2/bin:$PATH

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

source $HOME/.aliases.sh

source $HOME/.aws.sh

source $HOME/.functions.sh

# agnoster case:
DEFAULT_USER="$(whoami)"

# AGNOSTER_PROMPT_SEGMENTS=(
#     prompt_status
#     prompt_context
#     prompt_virtualenv
#     prompt_git
# )

prompt_context() {
   prompt_segment red white "$(date '+%Y-%m-%d %H:%M:%S') > $USER"
}

prompt_dir() {
    prompt_segment blue gray '%~'
}

# prompt_git() {
# }

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

complete -o nospace -C /usr/local/bin/terraform terraform

# PATH updates
export PATH="/usr/local/sbin:$PATH"

export PATH="/usr/local/opt/libpq/bin:$PATH"

export PATH="${HOME}/.gem/ruby/2.6.0/bin:$PATH"

# GPG requires TTY
# export GPG_TTY=$(tty)

# Set the default quoting style to literal
export QUOTING_STYLE=literal

# Created by `pipx`
export PATH="$PATH:$HOME/.local/bin"

# FZF - File Finder
eval "$(fzf --zsh)"

# # In order to reattach the screen with the SSH ForwardAgent
# # We need this method on the servers/remote machines:
if [ -z "${STY}" -a -t 0 ]; then
    reattach () {
        if [ -n "${SSH_AUTH_SOCK}" ]; then
            echo -e "linking...\n"
            ln -snf "${SSH_AUTH_SOCK}" "${HOME}/.ssh/agent-screen"
            export SSH_AUTH_SOCK=${HOME}/.ssh/agent-screen
        fi
        exec screen -r -d ${1:+"$@"}
    }
fi

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -f "/opt/homebrew/opt/chruby/share/chruby/chruby.sh" && -f "/opt/homebrew/opt/chruby/share/chruby/auto.sh" && -x "$(command -v chruby)" ]]; then
    source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
    source /opt/homebrew/opt/chruby/share/chruby/auto.sh
    chruby ruby-3.3.4
fi


if [[ -d "$HOME/Works/autodesk/etc/scripts/" ]]; then
    PATH="$HOME/Works/autodesk/etc/scripts/:$PATH"
fi

# rbenv
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init - zsh)"
fi

# # Github Copilot Commandline client integration
 eval "$(gh copilot alias -- zsh)"
