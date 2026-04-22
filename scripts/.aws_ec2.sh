#!/bin/bash

# AWS EC2 Functions
# Requires: aws, jq on PATH.
# aws-ec2-instances OS column uses ec2:DescribeImages on unique AMI IDs (IAM: ec2:DescribeImages).
# aws-amis: name filter uses AWS wildcard rules (* and ? are wildcards; max 1000 per page, all pages merged).

# True when stdout is a TTY and NO_COLOR is unset (https://no-color.org/).
_aws_ec2_color_enabled() {
    [[ -z "${NO_COLOR:-}" ]] && [[ -t 1 ]]
}

_aws_ec2_require_tools() {
    if ! command -v aws >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
        echo "aws_ec2.sh: need aws and jq on PATH" >&2
        return 1
    fi
}

# Opening ANSI for instance State.Name column (caller prints reset after field).
_aws_ec2_instance_state_color() {
    # When called via command substitution, stdout is not a TTY in the subshell.
    # Allow callers to pass a non-empty 2nd arg to explicitly enable colors.
    if [[ -n "${2+x}" ]]; then
        [[ -n "$2" ]] || {
            printf '%s' ""
            return
        }
    elif ! _aws_ec2_color_enabled; then
        printf '%s' ""
        return
    fi
    case "$1" in
        "running")       printf '%s' $'\033[1;32m' ;;
        "stopped")       printf '%s' $'\033[1;31m' ;;
        "pending")       printf '%s' $'\033[1;33m' ;;
        "stopping")      printf '%s' $'\033[0;33m' ;;
        "shutting-down") printf '%s' $'\033[0;91m' ;;
        "terminated")    printf '%s' $'\033[0;90m' ;;
        *)               printf '%s' $'\033[0;37m' ;;
    esac
}

# AMI Image.State for aws-amis output.
_aws_ec2_ami_state_color() {
    if ! _aws_ec2_color_enabled; then
        printf '%s' ""
        return
    fi
    case "$1" in
        "available") printf '%s' $'\033[1;32m' ;;
        "pending")   printf '%s' $'\033[1;33m' ;;
        "failed")    printf '%s' $'\033[1;31m' ;;
        *)           printf '%s' $'\033[0;37m' ;;
    esac
}

# Architecture column color for aws-amis.
_aws_ec2_arch_color() {
    if ! _aws_ec2_color_enabled; then
        printf '%s' ""
        return
    fi
    case "$1" in
        "x86_64") printf '%s' $'\033[0;36m' ;;
        "arm64")  printf '%s' $'\033[0;35m' ;;
        *)        printf '%s' $'\033[0;37m' ;;
    esac
}

aws-ec2-running-instances() {
    _aws_ec2_require_tools || return 1
    local C_RST C_HDR C_ID C_TYPE C_ST_RUN C_IP C_NAME
    if _aws_ec2_color_enabled; then
        C_RST=$'\033[0m'
        C_HDR=$'\033[1;37m'
        C_ID=$'\033[1;36m'
        C_TYPE=$'\033[0;32m'
        C_ST_RUN=$'\033[1;32m'
        C_IP=$'\033[0;34m'
        C_NAME=$'\033[0;35m'
    else
        C_RST='' C_HDR='' C_ID='' C_TYPE='' C_ST_RUN='' C_IP='' C_NAME=''
    fi
    (
        set -o pipefail
        printf "%s%-19s %-15s %-10s %-15s %s%s\n" "$C_HDR" "INSTANCE_ID" "TYPE" "STATE" "PRIVATE_IP" "NAME" "$C_RST"
        local reservations_json
        if ! reservations_json=$(aws ec2 describe-instances); then
            echo "aws-ec2-running-instances: aws ec2 describe-instances failed" >&2
            exit 1
        fi
        echo "$reservations_json" | jq -r '
            .Reservations[].Instances[] |
            select(.State.Code == 16) |
            [
                .InstanceId,
                .InstanceType,
                .State.Name,
                (.PrivateIpAddress // "N/A"),
                (.Tags[]? | select(.Key == "Name") | .Value // "")
            ] |
            @tsv
        ' | while IFS=$'\t' read -r instance_id type state private_ip name; do
            printf "%s%-19s%s %s%-15s%s %s%-10s%s %s%-15s%s %s%s%s\n" \
                "$C_ID" "$instance_id" "$C_RST" \
                "$C_TYPE" "$type" "$C_RST" \
                "$C_ST_RUN" "$state" "$C_RST" \
                "$C_IP" "$private_ip" "$C_RST" \
                "$C_NAME" "$name" "$C_RST"
        done
    ) || return 1
}

# AWS ALL INSTANCES
# Usage: aws-ec2-instances [--sort-by-ip] [--sort-by-name]
# OS column needs ec2:DescribeImages; falls back to PlatformDetails (often Linux/UNIX) if denied or unknown AMI.
aws-ec2-instances() {
    _aws_ec2_require_tools || return 1
    local sort_by_ip=false
    local sort_by_name=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --sort-by-ip)
                sort_by_ip=true
                shift
                ;;
            --sort-by-name)
                sort_by_name=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: aws-ec2-instances [--sort-by-ip] [--sort-by-name]"
                return 1
                ;;
        esac
    done

    if [[ "$sort_by_ip" == true && "$sort_by_name" == true ]]; then
        echo "Error: Cannot use both --sort-by-ip and --sort-by-name flags simultaneously"
        echo "Usage: aws-ec2-instances [--sort-by-ip] [--sort-by-name]"
        return 1
    fi

    local running=0 stopped=0 pending=0 stopping=0 shutting_down=0 terminated=0 other=0 total=0

    local reservations_json
    if ! reservations_json=$(aws ec2 describe-instances); then
        echo "aws-ec2-instances: aws ec2 describe-instances failed" >&2
        return 1
    fi

    local instance_data
    instance_data=$(echo "$reservations_json" | jq -r '
        .Reservations[].Instances[] |
        [
            .InstanceId,
            .InstanceType,
            .State.Name,
            (.PrivateIpAddress // "N/A"),
            ((.Tags[]? | select(.Key == "Name") | .Value) // ""),
            (.ImageId // "N/A"),
            (.Placement.AvailabilityZone // "N/A"),
            (.PlatformDetails // "N/A"),
            (.Platform // "")
        ] |
        @tsv
    ') || return 1

    local ami_ids_list
    ami_ids_list=$(echo "$reservations_json" | jq -r '
        [.Reservations[].Instances[].ImageId // empty]
        | map(select(. != null and . != ""))
        | unique
        | sort
        | .[]
    ') || return 1

    local jq_ami_os
    read -r -d '' jq_ami_os <<'JQE' || true
def classify($text):
    if ($text | length) == 0 then
        null
    else
        ($text | ascii_downcase) as $l |
        if ($l | test("windows_server|windows-server|microsoft windows")) then "Windows"
        elif ($l | contains("ubuntu-minimal")) then "Ubuntu Minimal"
        elif ($l | contains("ubuntu")) then "Ubuntu"
        elif ($l | test("ubuntu/images|/ubuntu/|ubuntu-")) then "Ubuntu"
        elif ($l | test("amazon linux 2023|al2023|al202[0-9]")) then "Amazon Linux 2023"
        elif ($l | test("amzn2|amazon linux 2")) then "Amazon Linux 2"
        elif ($l | test("amazon-linux-ami|amzn-ami|/amazon/|kernel-.*amzn")) then "Amazon Linux"
        elif ($l | contains("debian")) then "Debian"
        elif ($l | test("red hat enterprise|^rhel|rhel[0-9]|redhat")) then "RHEL"
        elif ($l | contains("centos")) then "CentOS"
        elif ($l | contains("rocky")) then "Rocky Linux"
        elif ($l | test("^sles|suse linux|suse-sles|suse-sap")) then "SUSE"
        elif ($l | contains("alpine")) then "Alpine"
        elif ($l | contains("kali")) then "Kali Linux"
        elif ($l | test("fedora cloud|fedora coreos")) then "Fedora"
        elif ($l | contains("oracle linux")) then "Oracle Linux"
        else null
        end
    end;
def owner_hint($owner):
    if ($owner == null or $owner == "") then
        null
    elif ($owner == "137112412989") then "Amazon Linux"
    elif ($owner == "099720109477") then "Ubuntu"
    elif ($owner == "136693071363") then "Debian"
    elif ($owner == "792107900819") then "Rocky Linux"
    elif ($owner == "774657347311") then "AlmaLinux"
    elif ($owner == "309956499498") then "RHEL"
    elif ($owner == "013907871322") then "SUSE"
    elif ($owner == "679593333241") then "Bitnami"
    elif ($owner == "900890692086") then "Oracle Linux"
    else null
    end;
.Images[] |
    .ImageId as $id |
    (.OwnerId // "") as $owner |
    (.Name // "") as $n |
    (.Description // "") as $d |
    (.ImageLocation // "") as $loc |
    (
        classify($n) // classify($d) // classify($loc)
        // owner_hint($owner)
    ) as $os |
    [$id, ($os // "")] | @tsv
JQE

    local ami_os_map=""
    if [[ -n "$ami_ids_list" && -n "$jq_ami_os" ]]; then
        # Use an array for --image-ids: unquoted "$batch" does not split words when this file is sourced from zsh,
        # which produced a single malformed id like "ami-xxx ami-yyy ...".
        local -a batch_ids=()
        local chunk
        while IFS= read -r aid || [[ -n "$aid" ]]; do
            [[ -z "$aid" ]] && continue
            batch_ids+=("$aid")
            if [[ "${#batch_ids[@]}" -ge 200 ]]; then
                chunk=$(aws ec2 describe-images --image-ids "${batch_ids[@]}" | jq -r "$jq_ami_os" 2>/dev/null) || chunk=""
                ami_os_map="${ami_os_map}${chunk}"$'\n'
                batch_ids=()
            fi
        done <<< "$ami_ids_list"
        if [[ "${#batch_ids[@]}" -gt 0 ]]; then
            chunk=$(aws ec2 describe-images --image-ids "${batch_ids[@]}" | jq -r "$jq_ami_os" 2>/dev/null) || chunk=""
            ami_os_map="${ami_os_map}${chunk}"$'\n'
        fi
    fi

    local ami_map_file
    ami_map_file=$(mktemp "${TMPDIR:-/tmp}/aws-ec2-instances.ami-map.XXXXXX") || return 1
    printf '%s\n' "$ami_os_map" >"$ami_map_file"

    local instance_rows
    instance_rows=$(echo "$instance_data" | awk -F'\t' -v os_map_file="$ami_map_file" '
        BEGIN {
            while ((getline line < os_map_file) > 0) {
                split(line, a, "\t")
                if (a[1] != "") {
                    map[a[1]] = a[2]
                }
            }
            close(os_map_file)
        }
        {
            ami = $6
            pd = $8
            plat = $9
            os = map[ami]
            if (plat == "windows") {
                os = "Windows"
            } else if (os == "") {
                os = pd
            }
            # id type state private_ip az name ami os (AZ next to private IP)
            print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $7 "\t" $5 "\t" $6 "\t" os
        }
    ')
    rm -f "$ami_map_file"

    while IFS=$'\t' read -r instance_id type state private_ip name ami_id az platform_details platform; do
        case "$state" in
            "running")   ((running++)) ;;
            "stopped")   ((stopped++)) ;;
            "pending")   ((pending++)) ;;
            "stopping")  ((stopping++)) ;;
            "shutting-down") ((shutting_down++)) ;;
            "terminated") ((terminated++)) ;;
            *)           ((other++)) ;;
        esac
        ((total++))
    done <<< "$instance_data"

    local C_RST C_HDR C_ID C_TYPE C_IP C_AMI C_OS C_AZ C_NAME
    if _aws_ec2_color_enabled; then
        C_RST=$'\033[0m'
        C_HDR=$'\033[1;37m'
        C_ID=$'\033[1;36m'
        C_TYPE=$'\033[0;32m'
        C_IP=$'\033[0;34m'
        C_AMI=$'\033[1;35m'
        C_OS=$'\033[0;36m'
        C_AZ=$'\033[0;33m'
        C_NAME=$'\033[0;35m'
    else
        C_RST='' C_HDR='' C_ID='' C_TYPE='' C_IP='' C_AMI='' C_OS='' C_AZ='' C_NAME=''
    fi

    (
        set -o pipefail
        printf "%s%-19s %-15s %-14s %-15s %-14s %-21s %-18s %s%s\n" \
            "$C_HDR" "INSTANCE_ID" "TYPE" "STATE" "PRIVATE_IP" "AZ" "AMI_ID" "OS" "NAME" "$C_RST"

        local state_color
        if [[ "$sort_by_ip" == true ]]; then
            echo "$instance_rows" | sort -t$'\t' -k4 -V | while IFS=$'\t' read -r instance_id type state private_ip az name ami_id os; do
                state_color=$(_aws_ec2_instance_state_color "$state" "$C_RST")
                printf "%s%-19s%s %s%-15s%s %s%-14s%s %s%-15s%s %s%-14s%s %s%-21s%s %s%-18s%s %s%s%s\n" \
                    "$C_ID" "$instance_id" "$C_RST" \
                    "$C_TYPE" "$type" "$C_RST" \
                    "$state_color" "$state" "$C_RST" \
                    "$C_IP" "$private_ip" "$C_RST" \
                    "$C_AZ" "$az" "$C_RST" \
                    "$C_AMI" "$ami_id" "$C_RST" \
                    "$C_OS" "$os" "$C_RST" \
                    "$C_NAME" "$name" "$C_RST"
            done
        elif [[ "$sort_by_name" == true ]]; then
            echo "$instance_rows" | sort -t$'\t' -k6 | while IFS=$'\t' read -r instance_id type state private_ip az name ami_id os; do
                state_color=$(_aws_ec2_instance_state_color "$state" "$C_RST")
                printf "%s%-19s%s %s%-15s%s %s%-14s%s %s%-15s%s %s%-14s%s %s%-21s%s %s%-18s%s %s%s%s\n" \
                    "$C_ID" "$instance_id" "$C_RST" \
                    "$C_TYPE" "$type" "$C_RST" \
                    "$state_color" "$state" "$C_RST" \
                    "$C_IP" "$private_ip" "$C_RST" \
                    "$C_AZ" "$az" "$C_RST" \
                    "$C_AMI" "$ami_id" "$C_RST" \
                    "$C_OS" "$os" "$C_RST" \
                    "$C_NAME" "$name" "$C_RST"
            done
        else
            echo "$instance_rows" | while IFS=$'\t' read -r instance_id type state private_ip az name ami_id os; do
                state_color=$(_aws_ec2_instance_state_color "$state" "$C_RST")
                printf "%s%-19s%s %s%-15s%s %s%-14s%s %s%-15s%s %s%-14s%s %s%-21s%s %s%-18s%s %s%s%s\n" \
                    "$C_ID" "$instance_id" "$C_RST" \
                    "$C_TYPE" "$type" "$C_RST" \
                    "$state_color" "$state" "$C_RST" \
                    "$C_IP" "$private_ip" "$C_RST" \
                    "$C_AZ" "$az" "$C_RST" \
                    "$C_AMI" "$ami_id" "$C_RST" \
                    "$C_OS" "$os" "$C_RST" \
                    "$C_NAME" "$name" "$C_RST"
            done
        fi
    ) || return 1

    echo
    if _aws_ec2_color_enabled; then
        printf "\033[1;37mStatistics: \033[0m"
        [[ $running -gt 0 ]] && printf "\033[1;32m%d running\033[0m " "$running"
        [[ $stopped -gt 0 ]] && printf "\033[1;31m%d stopped\033[0m " "$stopped"
        [[ $pending -gt 0 ]] && printf "\033[1;33m%d pending\033[0m " "$pending"
        [[ $stopping -gt 0 ]] && printf "\033[0;33m%d stopping\033[0m " "$stopping"
        [[ $shutting_down -gt 0 ]] && printf "\033[0;91m%d shutting-down\033[0m " "$shutting_down"
        [[ $terminated -gt 0 ]] && printf "\033[0;90m%d terminated\033[0m " "$terminated"
        [[ $other -gt 0 ]] && printf "\033[0;37m%d other\033[0m " "$other"
        printf "\033[1;37m| Total: %d instances\033[0m\n" "$total"
    else
        printf "Statistics: "
        [[ $running -gt 0 ]] && printf "%d running " "$running"
        [[ $stopped -gt 0 ]] && printf "%d stopped " "$stopped"
        [[ $pending -gt 0 ]] && printf "%d pending " "$pending"
        [[ $stopping -gt 0 ]] && printf "%d stopping " "$stopping"
        [[ $shutting_down -gt 0 ]] && printf "%d shutting-down " "$shutting_down"
        [[ $terminated -gt 0 ]] && printf "%d terminated " "$terminated"
        [[ $other -gt 0 ]] && printf "%d other " "$other"
        printf "| Total: %d instances\n" "$total"
    fi
}

# AWS LIST AMIS
# Usage: aws-amis [--include-public] [--search-name <pattern>] [--sort-by-name|--sort-by-date]
# --search-name: substring match on AMI name; AWS treats * and ? as wildcards in the filter value.
# Results paginate at 1000 images per API call; all pages are merged (may be slow for huge result sets).
aws-amis() {
    _aws_ec2_require_tools || return 1
    local include_public=false
    local search_pattern=""
    local sort_option="name"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --include-public)
                include_public=true
                shift
                ;;
            --search-name)
                search_pattern="$2"
                shift 2
                ;;
            --sort-by-name)
                sort_option="name"
                shift
                ;;
            --sort-by-date)
                sort_option="date"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: aws-amis [--include-public] [--search-name <pattern>] [--sort-by-name|--sort-by-date]"
                return 1
                ;;
        esac
    done

    local -a aws_amis_args=()
    if [[ "$include_public" == true ]]; then
        aws_amis_args+=(--owners self amazon)
    fi
    if [[ -n "$search_pattern" ]]; then
        aws_amis_args+=(--filters "Name=state,Values=available" "Name=name,Values=*${search_pattern}*")
    else
        aws_amis_args+=(--filters "Name=state,Values=available")
    fi

    local -a pages=()
    local next_token=""
    local page
    while true; do
        if [[ -n "$next_token" ]]; then
            if ! page=$(aws ec2 describe-images "${aws_amis_args[@]}" --max-items 1000 --starting-token "$next_token"); then
                echo "aws-amis: aws ec2 describe-images failed" >&2
                return 1
            fi
        else
            if ! page=$(aws ec2 describe-images "${aws_amis_args[@]}" --max-items 1000); then
                echo "aws-amis: aws ec2 describe-images failed" >&2
                return 1
            fi
        fi
        pages+=("$page")
        next_token=$(echo "$page" | jq -r '.NextToken // empty')
        [[ -z "$next_token" ]] && break
    done

    local aws_result
    if [[ ${#pages[@]} -eq 0 ]]; then
        aws_result='{"Images":[]}'
    else
        # Always merge paginator pages to stay shell-agnostic (bash is 0-indexed, zsh is 1-indexed).
        if ! aws_result=$(printf '%s\n' "${pages[@]}" | jq -s 'map(.Images // []) | add | {Images: .}'); then
            echo "aws-amis: failed to merge describe-images pages" >&2
            return 1
        fi
    fi

    local C_RST C_HDR C_ID C_NAME C_OWN C_DATE C_DESC
    if _aws_ec2_color_enabled; then
        C_RST=$'\033[0m'
        C_HDR=$'\033[1;37m'
        C_ID=$'\033[1;34m'
        C_NAME=$'\033[0;33m'
        C_OWN=$'\033[0;35m'
        C_DATE=$'\033[0;32m'
        C_DESC=$'\033[0;37m'
    else
        C_RST='' C_HDR='' C_ID='' C_NAME='' C_OWN='' C_DATE='' C_DESC=''
    fi

    (
        set -o pipefail
        printf "%s%-21s %-60s %-15s %-12s %-8s %-12s %s%s\n" \
            "$C_HDR" "AMI_ID" "NAME" "STATE" "OWNER_ID" "ARCH" "DATE" "DESCRIPTION" "$C_RST"

        echo "$aws_result" | jq -r '
            .Images[] |
            [
                .ImageId,
                (.Name // "N/A"),
                .State,
                .OwnerId,
                .Architecture,
                (.CreationDate // "" | split("T")[0]),
                (.Description // ""),
                (.CreationDate // "")
            ] |
            @tsv
        ' | while IFS=$'\t' read -r ami_id name state owner_id arch formatted_date description creation_date; do
            if [[ ${#description} -gt 80 ]]; then
                description="${description:0:77}..."
            fi
            if [[ ${#name} -gt 60 ]]; then
                name="${name:0:57}..."
            fi
            printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
                "$ami_id" "$name" "$state" "$owner_id" "$arch" "$formatted_date" "$description" "$creation_date"
        done | {
            case "$sort_option" in
                "date")
                    sort -t$'\t' -k8 -r
                    ;;
                *)
                    sort -t$'\t' -k2
                    ;;
            esac
        } | while IFS=$'\t' read -r ami_id name state owner_id arch formatted_date description creation_date; do
            state_color=$(_aws_ec2_ami_state_color "$state")
            arch_color=$(_aws_ec2_arch_color "$arch")
            printf "%s%-21s%s %s%-60s%s %s%-15s%s %s%-12s%s %s%-8s%s %s%-12s%s %s%s%s\n" \
                "$C_ID" "$ami_id" "$C_RST" \
                "$C_NAME" "$name" "$C_RST" \
                "$state_color" "$state" "$C_RST" \
                "$C_OWN" "$owner_id" "$C_RST" \
                "$arch_color" "$arch" "$C_RST" \
                "$C_DATE" "$formatted_date" "$C_RST" \
                "$C_DESC" "$description" "$C_RST"
        done
    ) || return 1

    local total_count
    total_count=$(echo "$aws_result" | jq '.Images | length')
    echo
    if _aws_ec2_color_enabled; then
        printf "\033[1;37mTotal AMIs found: \033[1;36m%d\033[0m" "$total_count"
        [[ "$include_public" == true ]] && printf " \033[0;37m(including public images)\033[0m"
        if [[ -n "$search_pattern" ]]; then
            printf " \033[0;37m(filtered by name; * and ? are AWS wildcards: '%s')\033[0m" "$search_pattern"
        fi
        printf "\n"
    else
        printf "Total AMIs found: %d" "$total_count"
        [[ "$include_public" == true ]] && printf " (including public images)"
        if [[ -n "$search_pattern" ]]; then
            printf " (filtered by name; * and ? are AWS wildcards: '%s')" "$search_pattern"
        fi
        printf "\n"
    fi
}
