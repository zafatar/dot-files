#!/bin/bash

# Function to remove all known_hosts entries starting with a given IP
remove_ssh_known_hosts_by_ip() {
    local ip="$1"
    local known_hosts="${HOME}/.ssh/known_hosts"
    
    # Check if IP parameter is provided
    if [ -z "$ip" ]; then
        echo "Error: No IP address provided"
        echo "Usage: remove_ssh_known_hosts_by_ip <ip_address>"
        return 1
    fi
    
    # Check if known_hosts file exists
    if [ ! -f "$known_hosts" ]; then
        echo "Error: ${known_hosts} not found"
        return 1
    fi
    
    # Create a backup
    cp "$known_hosts" "${known_hosts}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backup created: ${known_hosts}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Count matching entries before removal
    local count=$(grep -c "^${ip}" "$known_hosts" 2>/dev/null || echo 0)
    
    if [ "$count" -eq 0 ]; then
        echo "No entries found starting with IP: ${ip}"
        return 0
    fi
    
    # Remove entries starting with the given IP
    # Use different sed syntax for macOS vs Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^${ip}/d" "$known_hosts"
    else
        sed -i "/^${ip}/d" "$known_hosts"
    fi
    
    
    echo "Removed ${count} entry/entries starting with IP: ${ip}"
    return 0
}