#!/bin/bash
#
# Open new Terminal tabs from the command line
#
[ `uname -s` != "Darwin" ] && return

function tab () {
    local cmd=""
    local cdto="$PWD"
    local args="$@"

    if [ -d "$1" ]; then
        cdto=`cd "$1"; pwd`
        args="${@:2}"
    fi

    if [ -n "$args" ]; then
        cmd="; $args"
    fi

    osascript &>/dev/null <<EOF
        tell application "iTerm"
             tell current window
             	  set newTab to (create tab with default profile)
            	  tell current session of newTab
                       write text "title $tab_name; cd \"$cdto\"$cmd"
            	  end tell
             end tell
    	end tell
EOF
}

function tab-color() {
    echo -ne "\033]6;1;bg;red;brightness;$1\a"
    echo -ne "\033]6;1;bg;green;brightness;$2\a"
    echo -ne "\033]6;1;bg;blue;brightness;$3\a"
}

function tab-reset() {
    echo -ne "\033]6;1;bg;*;default\a"
    printf "\e]1337;SetBadgeFormat=%s\a" $(echo "(done)" | base64)
}