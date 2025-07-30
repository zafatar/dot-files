#!/bin/bash

# AWS S3 Functions
# This file contains all S3-related AWS CLI wrapper functions

# AWS S3 BUCKETS - List buckets with detailed information
# Usage: aws-s3-buckets [--sort-by-size|--sort-by-date|--sort-by-name]
aws-s3-buckets() {
    local sort_option=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --sort-by-size)
                sort_option="size"
                shift
                ;;
            --sort-by-date)
                sort_option="date"
                shift
                ;;
            --sort-by-name)
                sort_option="name"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: aws-s3-buckets [--sort-by-size|--sort-by-date|--sort-by-name]"
                return 1
                ;;
        esac
    done
    
    (
        printf "\033[1;37m%-25s %-12s %-15s %-12s %s\033[0m\n" "BUCKET_NAME" "ENCRYPTED" "REGION" "SIZE" "CREATED"
        
        # Get bucket list and process each bucket
        aws s3api list-buckets | jq -r '.Buckets[] | [.Name, .CreationDate] | @tsv' | while IFS=$'\t' read -r bucket_name creation_date; do
            # Get encryption status
            encryption_status=$(aws s3api get-bucket-encryption --bucket "$bucket_name" 2>/dev/null | jq -r '.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm // "None"' 2>/dev/null || echo "None")
            
            # Get bucket region
            region=$(aws s3api get-bucket-location --bucket "$bucket_name" 2>/dev/null | jq -r '.LocationConstraint // "us-east-1"' 2>/dev/null || echo "Unknown")
            if [ "$region" = "null" ]; then
                region="us-east-1"
            fi
            
            # Get bucket size (this can be slow for large buckets)
            size_info=$(aws s3 ls s3://"$bucket_name" --recursive --summarize 2>/dev/null | tail -2 | grep "Total Size" | awk '{print $3}' || echo "0")
            if [ -z "$size_info" ] || [ "$size_info" = "0" ]; then
                size_display="Empty"
            else
                # Convert bytes to human readable format
                if [ "$size_info" -gt 1073741824 ]; then
                    size_display=$(echo "scale=1; $size_info / 1073741824" | bc 2>/dev/null || echo "0")
                    size_display="${size_display}GB"
                elif [ "$size_info" -gt 1048576 ]; then
                    size_display=$(echo "scale=1; $size_info / 1048576" | bc 2>/dev/null || echo "0")
                    size_display="${size_display}MB"
                elif [ "$size_info" -gt 1024 ]; then
                    size_display=$(echo "scale=1; $size_info / 1024" | bc 2>/dev/null || echo "0")
                    size_display="${size_display}KB"
                else
                    size_display="${size_info}B"
                fi
            fi
            
            # Format creation date
            formatted_date=$(echo "$creation_date" | cut -d'T' -f1 2>/dev/null || echo "$creation_date")
            
            # Color encryption status
            case "$encryption_status" in
                "None")      encryption_color=$'\033[1;31m' ;;  # Bright Red
                "AES256")    encryption_color=$'\033[1;32m' ;;  # Bright Green
                "aws:kms")   encryption_color=$'\033[1;36m' ;;  # Bright Cyan
                *)           encryption_color=$'\033[0;37m' ;;  # Light Gray
            esac
            
            # Output the formatted line with size info for sorting
            printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
                "$bucket_name" "$encryption_status" "$region" "$size_display" "$formatted_date" "$size_info"
        done | {
            # Sort based on the option
            case "$sort_option" in
                "size")
                    sort -t$'\t' -k6 -n -r
                    ;;
                "date")
                    sort -t$'\t' -k5 -r
                    ;;
                "name")
                    sort -t$'\t' -k1
                    ;;
                *)
                    cat
                    ;;
            esac
        } | while IFS=$'\t' read -r bucket_name encryption_status region size_display formatted_date size_info; do
            # Color encryption status
            case "$encryption_status" in
                "None")      encryption_color=$'\033[1;31m' ;;  # Bright Red
                "AES256")    encryption_color=$'\033[1;32m' ;;  # Bright Green
                "aws:kms")   encryption_color=$'\033[1;36m' ;;  # Bright Cyan
                *)           encryption_color=$'\033[0;37m' ;;  # Light Gray
            esac
            
            printf "\033[1;34m%-25s\033[0m ${encryption_color}%-12s\033[0m \033[0;33m%-15s\033[0m \033[0;36m%-12s\033[0m \033[0;35m%s\033[0m\n" \
                "$bucket_name" "$encryption_status" "$region" "$size_display" "$formatted_date"
        done
    )
}

# AWS S3 BUCKETS FAST - List buckets without size calculation (much faster)
# Usage: aws-s3-buckets-fast [--sort-by-date|--sort-by-name]
aws-s3-buckets-fast() {
    local sort_option=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --sort-by-date)
                sort_option="date"
                shift
                ;;
            --sort-by-name)
                sort_option="name"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: aws-s3-buckets-fast [--sort-by-date|--sort-by-name]"
                return 1
                ;;
        esac
    done
    
    (
        printf "\033[1;37m%-30s %-12s %-15s %s\033[0m\n" "BUCKET_NAME" "ENCRYPTED" "REGION" "CREATED"
        
        # Get bucket list and process each bucket
        aws s3api list-buckets | jq -r '.Buckets[] | [.Name, .CreationDate] | @tsv' | while IFS=$'\t' read -r bucket_name creation_date; do
            # Get encryption status
            encryption_status=$(aws s3api get-bucket-encryption --bucket "$bucket_name" 2>/dev/null | jq -r '.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm // "None"' 2>/dev/null || echo "None")
            
            # Get bucket region
            region=$(aws s3api get-bucket-location --bucket "$bucket_name" 2>/dev/null | jq -r '.LocationConstraint // "us-east-1"' 2>/dev/null || echo "Unknown")
            if [ "$region" = "null" ]; then
                region="us-east-1"
            fi
            
            # Format creation date
            formatted_date=$(echo "$creation_date" | cut -d'T' -f1 2>/dev/null || echo "$creation_date")
            
            # Output the formatted line for sorting
            printf "%s\t%s\t%s\t%s\n" \
                "$bucket_name" "$encryption_status" "$region" "$formatted_date"
        done | {
            # Sort based on the option
            case "$sort_option" in
                "date")
                    sort -t$'\t' -k4 -r
                    ;;
                "name")
                    sort -t$'\t' -k1
                    ;;
                *)
                    cat
                    ;;
            esac
        } | while IFS=$'\t' read -r bucket_name encryption_status region formatted_date; do
            # Color encryption status
            case "$encryption_status" in
                "None")      encryption_color=$'\033[1;31m' ;;  # Bright Red
                "AES256")    encryption_color=$'\033[1;32m' ;;  # Bright Green
                "aws:kms")   encryption_color=$'\033[1;36m' ;;  # Bright Cyan
                *)           encryption_color=$'\033[0;37m' ;;  # Light Gray
            esac
            
            printf "\033[1;34m%-30s\033[0m ${encryption_color}%-12s\033[0m \033[0;33m%-15s\033[0m \033[0;35m%s\033[0m\n" \
                "$bucket_name" "$encryption_status" "$region" "$formatted_date"
        done
    )
} 