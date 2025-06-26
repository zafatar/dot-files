#!/bin/bash
set -euo pipefail

# Dotfiles Backup Utility
# ========================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
readonly DEFAULT_BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "ERROR")   echo -e "${RED}❌ $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "INFO")    echo -e "${BLUE}ℹ️  $message${NC}" ;;
        *)         echo "$message" ;;
    esac
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [BACKUP_DIR]

Create a backup of existing dotfiles before installation.

Arguments:
    BACKUP_DIR          Optional backup directory (default: $DEFAULT_BACKUP_DIR)

Options:
    -h, --help          Show this help message
    -l, --list          List files that would be backed up
    -r, --restore DIR   Restore from backup directory

Examples:
    $0                                  # Create backup with default name
    $0 ~/my-backup                      # Create backup in specific location
    $0 --list                          # Show what would be backed up
    $0 --restore ~/.dotfiles-backup-*  # Restore from backup

EOF
}

get_dotfiles_list() {
    local files=(
        "$HOME/.zshrc"
        "$HOME/.aliases.sh"
        "$HOME/.aliases-git.sh"
        "$HOME/.color-tab.iterm.sh"
        "$HOME/.completion-git.sh"
        "$HOME/.gitconfig"
        "$HOME/.vimrc"
        "$HOME/.tmux.conf"
    )
    
    # Add config files
    if [[ -d "$HOME/.config" ]]; then
        if [[ -f "$HOME/.config/git/config" ]]; then
            files+=("$HOME/.config/git/config")
        fi
    fi
    
    # Return existing files only
    for file in "${files[@]}"; do
        if [[ -f "$file" || -L "$file" ]]; then
            echo "$file"
        fi
    done
}

list_files() {
    log "INFO" "Files that would be backed up:"
    echo
    
    local count=0
    while IFS= read -r file; do
        if [[ -L "$file" ]]; then
            printf "  📎 %s -> %s\n" "$file" "$(readlink "$file")"
        else
            printf "  📄 %s\n" "$file"
        fi
        ((count++))
    done < <(get_dotfiles_list)
    
    echo
    log "INFO" "Total files: $count"
}

create_backup() {
    local backup_dir="${1:-$DEFAULT_BACKUP_DIR}"
    
    log "INFO" "Creating backup directory: $backup_dir"
    mkdir -p "$backup_dir"
    
    local count=0
    while IFS= read -r file; do
        local filename="$(basename "$file")"
        local backup_path="$backup_dir/$filename"
        
        if [[ -L "$file" ]]; then
            # For symlinks, copy the target file
            if cp -L "$file" "$backup_path" 2>/dev/null; then
                log "SUCCESS" "Backed up (symlink): $file"
                ((count++))
            else
                log "WARNING" "Failed to backup symlink: $file"
            fi
        else
            # For regular files
            if cp "$file" "$backup_path" 2>/dev/null; then
                log "SUCCESS" "Backed up: $file"
                ((count++))
            else
                log "WARNING" "Failed to backup: $file"
            fi
        fi
    done < <(get_dotfiles_list)
    
    # Create a manifest file
    {
        echo "# Dotfiles Backup Manifest"
        echo "# Created: $(date)"
        echo "# Backup Directory: $backup_dir"
        echo "# Files backed up: $count"
        echo ""
        get_dotfiles_list
    } > "$backup_dir/MANIFEST.txt"
    
    log "SUCCESS" "Backup completed: $count files backed up to $backup_dir"
    log "INFO" "Manifest created: $backup_dir/MANIFEST.txt"
}

restore_backup() {
    local backup_dir="$1"
    
    if [[ ! -d "$backup_dir" ]]; then
        log "ERROR" "Backup directory not found: $backup_dir"
        return 1
    fi
    
    if [[ ! -f "$backup_dir/MANIFEST.txt" ]]; then
        log "WARNING" "No manifest found in backup directory"
    else
        log "INFO" "Backup manifest:"
        head -10 "$backup_dir/MANIFEST.txt"
        echo
    fi
    
    log "INFO" "Restoring from backup: $backup_dir"
    
    local count=0
    for backup_file in "$backup_dir"/*; do
        if [[ -f "$backup_file" && "$(basename "$backup_file")" != "MANIFEST.txt" ]]; then
            local filename="$(basename "$backup_file")"
            local target_file="$HOME/$filename"
            
            # Remove existing file/symlink
            if [[ -e "$target_file" || -L "$target_file" ]]; then
                rm -f "$target_file"
            fi
            
            # Restore file
            if cp "$backup_file" "$target_file"; then
                log "SUCCESS" "Restored: $target_file"
                ((count++))
            else
                log "ERROR" "Failed to restore: $target_file"
            fi
        fi
    done
    
    log "SUCCESS" "Restore completed: $count files restored"
}

main() {
    local backup_dir=""
    local list_only=false
    local restore_mode=false
    local restore_dir=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            -r|--restore)
                restore_mode=true
                restore_dir="$2"
                shift 2
                ;;
            -*)
                log "ERROR" "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                backup_dir="$1"
                shift
                ;;
        esac
    done
    
    if [[ "$list_only" == true ]]; then
        list_files
        exit 0
    fi
    
    if [[ "$restore_mode" == true ]]; then
        restore_backup "$restore_dir"
        exit $?
    fi
    
    # Create backup
    create_backup "$backup_dir"
}

main "$@" 