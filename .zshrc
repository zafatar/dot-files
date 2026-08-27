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

# Startup settings for oh-my-zsh. Each of these removes work that otherwise
# happens on *every* shell start:
#   SHORT_HOST          - omz otherwise forks `scutil --get LocalHostName`.
#                         $HOST holds the same value, so $ZSH_COMPDUMP keeps
#                         its existing filename and no cache is invalidated.
#   ZSH_DISABLE_COMPFIX - skips compaudit, which stats every fpath directory.
#   omz:update disabled - skips check_for_upgrade.sh, which forks git twice.
#                         Updates are still available on demand via `update`.
SHORT_HOST="${HOST%%.*}"
ZSH_DISABLE_COMPFIX=true
zstyle ':omz:update' mode disabled

# On macOS, omz probes `ls` and `gls` with real subprocesses just to pick a
# colour flag, then sets `alias ls='ls -G'` - which .aliases.sh overwrites with
# `ls -laG` further down anyway. Skip the probing and export the two colour
# variables verbatim from lib/theme-and-appearance.zsh instead.
#
# Linux is deliberately left alone: there omz builds LS_COLORS from `dircolors`,
# which gives a richer palette than the hardcoded fallback below.
if [[ "$OSTYPE" == darwin* ]]; then
    DISABLE_LS_COLORS=true
    export LSCOLORS="Gxfxcxdxbxegedabagacad"
    export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
fi

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

# Auto-update is disabled near the top of this file; run `update` by hand.

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

# Keep $path (and therefore $PATH) free of duplicates. Without this, every
# re-source of this file (e.g. the `resetshell` alias) appends the entries
# below again, so PATH grows without bound.
typeset -U path PATH

# Only prepend directories that exist - a missing PATH entry costs a failed stat
# on every command lookup for the life of the shell, and seven of the entries
# this file used to add are absent on this machine. The order below reproduces
# what the original run of separate `export PATH=` lines produced: entries later
# in the list end up earlier in $PATH.
for _dir in /opt/local/bin /opt/local/sbin /usr/local/bin /usr/local/go/bin \
            /opt/apache-maven-3.5.2/bin /usr/local/sbin \
            /usr/local/opt/libpq/bin "$HOME/.gem/ruby/2.6.0/bin" \
            /opt/homebrew/opt/libpq/bin; do
    [[ -d "$_dir" ]] && path=("$_dir" $path)
done
# ~/.local/bin (pipx) was *appended* by the original file, so it must not shadow
# anything earlier on PATH.
[[ -d "$HOME/.local/bin" ]] && path+=("$HOME/.local/bin")
unset _dir

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

source $HOME/.aliases.sh

source $HOME/.aws.sh

source $HOME/.functions.sh

# agnoster case:
DEFAULT_USER="$USER"

# AGNOSTER_PROMPT_SEGMENTS=(
#     prompt_status
#     prompt_context
#     prompt_virtualenv
#     prompt_git
# )

prompt_context() {
   # ${(%):-%D{...}} formats the time in-process; $(date ...) forked a process
   # on every prompt redraw.
   prompt_segment red white "${(%):-%D{%Y-%m-%d %H:%M:%S\}} > $USER"
}

prompt_dir() {
    prompt_segment blue gray '%~'
}

# prompt_git() {
# }

# Terraform ships a bash-style completion, so it needs bashcompinit (compinit
# itself already ran inside oh-my-zsh). Guarded on terraform actually being
# installed: the old line hardcoded /usr/local/bin/terraform, which does not
# exist on Apple Silicon, so it registered a completion for a missing binary.
# $commands[] is a zsh hash lookup, so the check costs no fork.
if (( $+commands[terraform] )); then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C "$commands[terraform]" terraform
fi

# GPG requires TTY. $TTY is maintained by zsh, so this avoids forking `tty`.
export GPG_TTY=$TTY

# Set the default quoting style to literal
export QUOTING_STYLE=literal

# FZF - File Finder
# Guarded so a box without fzf still starts a clean shell. `fzf --zsh` needs
# fzf >= 0.48; older builds (e.g. Debian 12) ship the same setup as files.
if (( $+commands[fzf] )); then
    # Cache `fzf --zsh` so a normal start sources a file instead of forking fzf.
    # Regenerated whenever the fzf binary is newer than the cache.
    _fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/fzf-init.zsh"
    if [[ ! -s "$_fzf_cache" || "$commands[fzf]" -nt "$_fzf_cache" ]]; then
        mkdir -p "${_fzf_cache:h}"
        fzf --zsh >| "$_fzf_cache" 2>/dev/null
    fi
    if [[ -s "$_fzf_cache" ]]; then
        source "$_fzf_cache"
    else
        for _fzf_file in /usr/share/doc/fzf/examples/key-bindings.zsh \
                         /usr/share/doc/fzf/examples/completion.zsh; do
            [[ -r "$_fzf_file" ]] && source "$_fzf_file"
        done
        unset _fzf_file
    fi
    unset _fzf_cache
fi

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Lazy-load chruby - only initializes when ruby/gem/bundle/chruby is first called
if [[ -f "/opt/homebrew/opt/chruby/share/chruby/chruby.sh" && -f "/opt/homebrew/opt/chruby/share/chruby/auto.sh" ]]; then
    _load_chruby() {
        unfunction chruby ruby gem bundle 2>/dev/null
        source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
        source /opt/homebrew/opt/chruby/share/chruby/auto.sh
        chruby ruby-3.3.4
    }
    chruby() { _load_chruby; chruby "$@"; }
    ruby()   { _load_chruby; ruby "$@"; }
    gem()    { _load_chruby; gem "$@"; }
    bundle() { _load_chruby; bundle "$@"; }
fi

if [[ -d "$HOME/Works/autodesk/etc/scripts/" ]]; then
    PATH="$HOME/Works/autodesk/etc/scripts/:$PATH"
fi

# Lazy-load rbenv - only initializes when rbenv is first called
rbenv() {
    unfunction rbenv
    eval "$(command rbenv init - zsh)"
    rbenv "$@"
}

# # Github Copilot Commandline client integration
# eval "$(gh copilot alias -- zsh)"

# NVM - node (lazy-loaded for fast shell startup)
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
    unfunction nvm node npm npx 2>/dev/null
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}
nvm()  { _load_nvm; nvm "$@"; }
node() { _load_nvm; node "$@"; }
npm()  { _load_nvm; npm "$@"; }
npx()  { _load_nvm; npx "$@"; }
