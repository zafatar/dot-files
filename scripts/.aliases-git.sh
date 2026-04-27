# ----------------------
# Git Aliases
# ----------------------
alias ga='git add'
alias gaa='git add .'
alias gaaa='git add --all'
alias gau='git add --update'
alias gb='git branch'
alias gbd='git branch --delete '
alias gc='git commit'
alias gcm='git commit --message'
alias gcf='git commit --fixup'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcom='git checkout master'
alias gcos='git checkout staging'
alias gcod='git checkout develop'
alias gd='git diff'
alias gda='git diff HEAD'
##### alias gi='git init'
alias gfp='git fetch --prune'
alias glg='git log --graph --oneline --decorate --all'
alias gld='git log --pretty=format:"%h %ad %s" --date=short --all'
alias gm='git merge --no-ff'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gp='git pull'
alias gpr='git pull --rebase'
alias gr='git rebase'
alias gs='git status'
alias gss='git status --short'
alias gst='git stash'
alias gsta='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash save'

# ----------------------
# Git Functions
# ----------------------
# Git log find by commit message
function glf() { git log --all --grep="$1"; }

function git-list-branches() { 
    local idx=0
    git for-each-ref --sort=-committerdate refs/remotes/origin \
        --format='%(refname:short)|%(committerdate:relative)|%(authorname)' | \
    while IFS='|' read -r branch reldate author; do
        [ "$branch" = "origin/HEAD" ] && continue
        counts=$(git rev-list --left-right --count develop..."$branch" 2>/dev/null) || continue
        ahead=$(echo "$counts" | awk '{print $2}')
        behind=$(echo "$counts" | awk '{print $1}')
        idx=$((idx + 1))
        printf '%3d  %-50s  %-20s  %-25s  ahead %4s | behind %4s\n' "$idx" "$branch" "$reldate" "$author" "$ahead" "$behind"
    done
}