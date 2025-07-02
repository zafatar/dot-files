#!/bin/bash

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
aws-all-instances-v2() {
    (
        printf "\033[1;37m%-19s %-15s %-12s %-15s %s\033[0m\n" "INSTANCE_ID" "TYPE" "STATE" "PRIVATE_IP" "NAME"
        aws ec2 describe-instances | jq -r '
            .Reservations[].Instances[] | 
            [
                .InstanceId, 
                .InstanceType, 
                .State.Name, 
                (.PrivateIpAddress // "N/A"), 
                ((.Tags[]? | select(.Key == "Name") | .Value) // "")
            ] | 
            @tsv
        ' | while IFS=$'\t' read -r instance_id type state private_ip name; do
            # Color states differently
            case "$state" in
                "running")   state_color=$'\033[1;32m' ;;  # Bright Green
                "stopped")   state_color=$'\033[1;31m' ;;  # Bright Red
                "pending")   state_color=$'\033[1;33m' ;;  # Bright Yellow
                "stopping")  state_color=$'\033[0;33m' ;;  # Yellow
                "terminated") state_color=$'\033[0;90m' ;; # Dark Gray
                *)           state_color=$'\033[0;37m' ;;  # Light Gray
            esac
            
            printf "\033[1;36m%-19s\033[0m \033[0;32m%-15s\033[0m ${state_color}%-12s\033[0m \033[0;34m%-15s\033[0m \033[0;35m%s\033[0m\n" \
                "$instance_id" "$type" "$state" "$private_ip" "$name"
        done
    )
}