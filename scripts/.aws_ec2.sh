#!/bin/bash

# AWS EC2 Functions
# This file contains all EC2-related AWS CLI wrapper functions

aws-running-instances-v2() {
    (
        printf "\033[1;37m%-19s %-15s %-10s %-15s %s\033[0m\n" "INSTANCE_ID" "TYPE" "STATE" "PRIVATE_IP" "NAME"
        aws ec2 describe-instances | jq -r '
            .Reservations[].Instances[] | 
            select(.State.Code == 16) | 
            [
                .InstanceId, 
                .InstanceType, 
                .State.Name, 
                .PrivateIpAddress, 
                (.Tags[]? | select(.Key == "Name") | .Value // "")
            ] | 
            @tsv
        ' | while IFS=$'\t' read -r instance_id type state private_ip name; do
            printf "\033[1;36m%-19s\033[0m \033[0;32m%-15s\033[0m \033[1;32m%-10s\033[0m \033[0;34m%-15s\033[0m \033[0;35m%s\033[0m\n" \
                "$instance_id" "$type" "$state" "$private_ip" "$name"
        done
    )
}

# AWS ALL INSTANCES - Fixed version with proper ANSI escape sequences
# Usage: aws-all-instances [--sort-by-ip] [--sort-by-name]
aws-all-instances() {
    local sort_by_ip=false
    local sort_by_name=false
    
    # Parse arguments
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
                echo "Usage: aws-all-instances [--sort-by-ip] [--sort-by-name]"
                return 1
                ;;
        esac
    done
    
    # Check for conflicting sort options
    if [[ "$sort_by_ip" == true && "$sort_by_name" == true ]]; then
        echo "Error: Cannot use both --sort-by-ip and --sort-by-name flags simultaneously"
        echo "Usage: aws-all-instances [--sort-by-ip] [--sort-by-name]"
        return 1
    fi
    
    # Initialize counters
    local running=0
    local stopped=0
    local pending=0
    local stopping=0
    local shutting_down=0
    local terminated=0
    local other=0
    local total=0
    
    # Get the raw data
    local instance_data=$(aws ec2 describe-instances | jq -r '
        .Reservations[].Instances[] | 
        [
            .InstanceId, 
            .InstanceType, 
            .State.Name, 
            (.PrivateIpAddress // "N/A"), 
            ((.Tags[]? | select(.Key == "Name") | .Value) // ""),
            (.ImageId // "N/A")
        ] | 
        @tsv
    ')
    
    # Count instances by state
    while IFS=$'\t' read -r instance_id type state private_ip name ami_id; do
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
    
    (
        printf "\033[1;37m%-19s %-15s %-14s %-15s %-21s %s\033[0m\n" "INSTANCE_ID" "TYPE" "STATE" "PRIVATE_IP" "AMI_ID" "NAME"
        
        # Sort and display the data
        if [ "$sort_by_ip" = true ]; then
            echo "$instance_data" | sort -t$'\t' -k4 -V | while IFS=$'\t' read -r instance_id type state private_ip name ami_id; do
                # Color states differently
                case "$state" in
                    "running")   state_color=$'\033[1;32m' ;;  # Bright Green
                    "stopped")   state_color=$'\033[1;31m' ;;  # Bright Red
                    "pending")   state_color=$'\033[1;33m' ;;  # Bright Yellow
                    "stopping")  state_color=$'\033[0;33m' ;;  # Yellow
                    "shutting-down") state_color=$'\033[0;91m' ;; # Bright Red (different shade)
                    "terminated") state_color=$'\033[0;90m' ;; # Dark Gray
                    *)           state_color=$'\033[0;37m' ;;  # Light Gray
                esac
                
                printf "\033[1;36m%-19s\033[0m \033[0;32m%-15s\033[0m ${state_color}%-14s\033[0m \033[0;34m%-15s\033[0m \033[1;35m%-21s\033[0m \033[0;35m%s\033[0m\n" \
                    "$instance_id" "$type" "$state" "$private_ip" "$ami_id" "$name"
            done
        elif [ "$sort_by_name" = true ]; then
            echo "$instance_data" | sort -t$'\t' -k5 | while IFS=$'\t' read -r instance_id type state private_ip name ami_id; do
                # Color states differently
                case "$state" in
                    "running")   state_color=$'\033[1;32m' ;;  # Bright Green
                    "stopped")   state_color=$'\033[1;31m' ;;  # Bright Red
                    "pending")   state_color=$'\033[1;33m' ;;  # Bright Yellow
                    "stopping")  state_color=$'\033[0;33m' ;;  # Yellow
                    "shutting-down") state_color=$'\033[0;91m' ;; # Bright Red (different shade)
                    "terminated") state_color=$'\033[0;90m' ;; # Dark Gray
                    *)           state_color=$'\033[0;37m' ;;  # Light Gray
                esac
                
                printf "\033[1;36m%-19s\033[0m \033[0;32m%-15s\033[0m ${state_color}%-14s\033[0m \033[0;34m%-15s\033[0m \033[1;35m%-21s\033[0m \033[0;35m%s\033[0m\n" \
                    "$instance_id" "$type" "$state" "$private_ip" "$ami_id" "$name"
            done
        else
            echo "$instance_data" | while IFS=$'\t' read -r instance_id type state private_ip name ami_id; do
                # Color states differently
                case "$state" in
                    "running")   state_color=$'\033[1;32m' ;;  # Bright Green
                    "stopped")   state_color=$'\033[1;31m' ;;  # Bright Red
                    "pending")   state_color=$'\033[1;33m' ;;  # Bright Yellow
                    "stopping")  state_color=$'\033[0;33m' ;;  # Yellow
                    "shutting-down") state_color=$'\033[0;91m' ;; # Bright Red (different shade)
                    "terminated") state_color=$'\033[0;90m' ;; # Dark Gray
                    *)           state_color=$'\033[0;37m' ;;  # Light Gray
                esac
                
                printf "\033[1;36m%-19s\033[0m \033[0;32m%-15s\033[0m ${state_color}%-14s\033[0m \033[0;34m%-15s\033[0m \033[1;35m%-21s\033[0m \033[0;35m%s\033[0m\n" \
                    "$instance_id" "$type" "$state" "$private_ip" "$ami_id" "$name"
            done
        fi
    )
    
    # Display statistics
    echo
    printf "\033[1;37mStatistics: \033[0m"
    [ $running -gt 0 ] && printf "\033[1;32m%d running\033[0m " "$running"
    [ $stopped -gt 0 ] && printf "\033[1;31m%d stopped\033[0m " "$stopped"
    [ $pending -gt 0 ] && printf "\033[1;33m%d pending\033[0m " "$pending"
    [ $stopping -gt 0 ] && printf "\033[0;33m%d stopping\033[0m " "$stopping"
    [ $shutting_down -gt 0 ] && printf "\033[0;91m%d shutting-down\033[0m " "$shutting_down"
    [ $terminated -gt 0 ] && printf "\033[0;90m%d terminated\033[0m " "$terminated"
    [ $other -gt 0 ] && printf "\033[0;37m%d other\033[0m " "$other"
    printf "\033[1;37m| Total: %d instances\033[0m\n" "$total"
} 

# AWS LIST AMIS - List AMIs in the AWS account
# Usage: aws-list-amis [--include-public] [--search-name <pattern>] [--sort-by-name|--sort-by-date]
aws-list-amis() {
    local include_public=false
    local search_pattern=""
    local sort_option="name"
    
    # Parse arguments
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
                echo "Usage: aws-list-amis [--include-public] [--search-name <pattern>] [--sort-by-name|--sort-by-date]"
                return 1
                ;;
        esac
    done
    
    # Execute AWS CLI directly to avoid shell expansion issues
    local aws_result
    if [ "$include_public" = true ]; then
        if [ -n "$search_pattern" ]; then
            aws_result=$(aws ec2 describe-images --owners self amazon --filters "Name=name,Values=*${search_pattern}*" "Name=state,Values=available" --max-items 1000)
        else
            aws_result=$(aws ec2 describe-images --owners self amazon --filters "Name=state,Values=available" --max-items 1000)
        fi
    else
        if [ -n "$search_pattern" ]; then
            aws_result=$(aws ec2 describe-images --filters "Name=name,Values=*${search_pattern}*" "Name=state,Values=available" --max-items 1000)
        else
            aws_result=$(aws ec2 describe-images --filters "Name=state,Values=available" --max-items 1000)
        fi
    fi
    
    (
        printf "\033[1;37m%-21s %-60s %-15s %-12s %-8s %-12s %s\033[0m\n" "AMI_ID" "NAME" "STATE" "OWNER_ID" "ARCH" "DATE" "DESCRIPTION"
        
        # Process the results
        echo "$aws_result" | jq -r '
            .Images[] | 
            [
                .ImageId,
                (.Name // "N/A"),
                .State,
                .OwnerId,
                .Architecture,
                .CreationDate,
                (.Description // "")
            ] | 
            @tsv
        ' | while IFS=$'\t' read -r ami_id name state owner_id arch creation_date description; do
            # Format creation date to show only date part
            formatted_date=$(echo "$creation_date" | cut -d'T' -f1 2>/dev/null || echo "$creation_date")
            
            # Truncate long descriptions
            if [ ${#description} -gt 80 ]; then
                description="${description:0:77}..."
            fi
            
            # Truncate long names
            if [ ${#name} -gt 60 ]; then
                name="${name:0:57}..."
            fi
            
            # Output for sorting with date info
            printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
                "$ami_id" "$name" "$state" "$owner_id" "$arch" "$formatted_date" "$description" "$creation_date"
        done | {
            # Sort based on the option
            case "$sort_option" in
                "date")
                    sort -t$'\t' -k7 -r  # Sort by full creation date (newest first)
                    ;;
                "name")
                    sort -t$'\t' -k2     # Sort by name
                    ;;
                *)
                    sort -t$'\t' -k2     # Default to name sorting
                    ;;
            esac
        } | while IFS=$'\t' read -r ami_id name state owner_id arch formatted_date description creation_date; do
            # Color states differently
            case "$state" in
                "available") state_color=$'\033[1;32m' ;;  # Bright Green
                "pending")   state_color=$'\033[1;33m' ;;  # Bright Yellow
                "failed")    state_color=$'\033[1;31m' ;;  # Bright Red
                *)           state_color=$'\033[0;37m' ;;  # Light Gray
            esac
            
            # Color architecture
            case "$arch" in
                "x86_64")    arch_color=$'\033[0;36m' ;;   # Cyan
                "arm64")     arch_color=$'\033[0;35m' ;;   # Magenta
                *)           arch_color=$'\033[0;37m' ;;   # Light Gray
            esac
            
            printf "\033[1;34m%-21s\033[0m \033[0;33m%-60s\033[0m ${state_color}%-15s\033[0m \033[0;35m%-12s\033[0m ${arch_color}%-8s\033[0m \033[0;32m%-12s\033[0m \033[0;37m%s\033[0m\n" \
                "$ami_id" "$name" "$state" "$owner_id" "$arch" "$formatted_date" "$description"
        done
    )
    
    # Display count statistics
    local total_count=$(echo "$aws_result" | jq '.Images | length')
    echo
    printf "\033[1;37mTotal AMIs found: \033[1;36m%d\033[0m" "$total_count"
    
    if [ "$include_public" = true ]; then
        printf " \033[0;37m(including public images)\033[0m"
    fi
    
    if [ -n "$search_pattern" ]; then
        printf " \033[0;37m(filtered by: '%s')\033[0m" "$search_pattern"
    fi
    
    printf "\n"
} 