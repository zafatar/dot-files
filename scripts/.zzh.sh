# ----------------------------------
# A custom way to ssh to the server.
# ----------------------------------

if [[ "$SHELL" =~ "bash" ]]; then
    declare -A ssh_connections
elif [[ "$SHELL" =~ "zsh" ]]; then
    typeset -A ssh_connections
else
    printf "This shell %s is not supported.\n" $SHELL
fi

input_file=$HOME'/.dot-files/scripts/.zzh.connections'
max_string_size=0

read_config_file() {
    while IFS=$' ' read -r ssh_alias ssh_conn ;
    do
        [[ "$ssh_alias" =~ ^#.* || "$ssh_alias" =~ ^\s*$ ]] && continue

        string_size=${#ssh_alias}
        if [[ $string_size -gt $max_string_size ]]; then
            max_string_size=$string_size
        fi

        if [[ "$SHELL" =~ "bash" ]]; then
            ssh_connections+=(["${ssh_alias}"]="${ssh_conn}")
        elif [[ "$SHELL" =~ "zsh" ]]; then
            ssh_connections[$ssh_alias]=$ssh_conn
        fi

    done < $1
}

zzh-list () {
    printf "\nAvailable connections for zzh:\n\n"

    if [[ "$SHELL" =~ "bash" ]]; then
        zzh-list-bash
    elif [[ "$SHELL" =~ "zsh" ]]; then
        zzh-list-zsh
    fi

    printf "\nDone.\n"
}

zzh-list-bash () {
    for ssh_alias in "${!ssh_connections[@]}"
    do
        # re-factor it - or find an elegant way to do it
        line_size=$((max_string_size + 5))
        line=''
        for i in $(seq 1 $line_size);
        do
            line=$line'-'
        done

        printf "\t%s %s [%s]\n" $ssh_alias "${line:${#ssh_alias}}" ${ssh_connections[$ssh_alias]}
    done
}

zzh-list-zsh () {
    for ssh_alias ssh_conn in ${(kv)ssh_connections};
    do
        # re-factor it - or find an elegant way to do it
        line_size=$((max_string_size + 5))
        line=''
        for i in $(seq 1 $line_size);
        do
            line=$line'-'
        done

        printf "\t%s %s [%s]\n" $ssh_alias "${line:${#ssh_alias}}" $ssh_conn
    done | sort -n -k3
}

zzh-load() {
    read_config_file $input_file
}

zzh() {
    if [[ -n "$ITERM_SESSION_ID" ]]; then
        trap "tab-reset" INT EXIT
        if [[ "$*" =~ "dev" ]]; then
            tab-color 255 0 0
        elif [[ "$*" =~ "prod" ]]; then
            tab-color 0 255 0
        elif [[ "$*" =~ "uat" ]]; then
            tab-color 0 0 255
        else
            tab-reset
        fi
    fi

    printf "\e]1337;SetBadgeFormat=%s\a" $(echo "$1" | base64)
    ssh "${ssh_connections[$*]}"

}

zzh-load