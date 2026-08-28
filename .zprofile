# Homebrew environment, inlined.
#
# This replaces `eval "$(/opt/homebrew/bin/brew shellenv)"`, which cost ~95ms of
# every login shell: it starts Homebrew's own bash script and then forks
# /usr/libexec/path_helper a second time, purely to print the static assignments
# below. /etc/zprofile has already run path_helper by this point, so prepending
# is equivalent. Verified byte-identical to `brew shellenv` output.
#
# If Homebrew ever moves, re-run `brew shellenv` and update these.
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" $path)
fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)

# Python.framework installs. The order here is deliberate and matches the three
# separate PATH= lines this replaces: each was prepended in turn, so the LAST
# one listed ends up furthest back. Net effect is that python3 resolves to
# 3.11 - not 3.12. Keep 3.11 last unless you actually want to change that.
for _v in 3.12 3.10 3.11; do
    [[ -d "/Library/Frameworks/Python.framework/Versions/$_v/bin" ]] &&
        path=("/Library/Frameworks/Python.framework/Versions/$_v/bin" $path)
done
unset _v

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Created by `pipx` on 2024-05-31 14:12:12
path+=("$HOME/.local/bin")
