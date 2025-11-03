#!/bin/bash

set -euo pipefail

# Modern Dotfiles Installer
# =========================

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$SCRIPT_DIR"
readonly BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
readonly LOG_FILE="$DOTFILES_DIR/install.log"
readonly CONFIG_FILE="$DOTFILES_DIR/config/install.yaml"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        "ERROR")   echo -e "${RED}❌ $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "INFO")    echo -e "${BLUE}ℹ️  $message${NC}" ;;
        *)         echo "$message" ;;
    esac
}

# Error handling
error_exit() {
    log "ERROR" "$1"
    echo -e "${RED}Installation failed. Check $LOG_FILE for details.${NC}"
    exit 1
}

# Cleanup function
cleanup() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error_exit "This script should not be run as root"
    fi
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check for Debian-based systems
        if command -v apt-get >/dev/null 2>&1; then
            echo "linux-deb"
        # Check for Arch-based systems
        elif command -v pacman >/dev/null 2>&1; then
            echo "linux-arch"
        else
            error_exit "Unsupported Linux distribution. Only Debian and Arch-based systems are supported."
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
    else
        error_exit "Unsupported OS: $OSTYPE"
    fi
}

# Create backup
create_backup() {
    local files_to_backup=(
        "$HOME/.zshrc"
        "$HOME/.aliases.sh"
        "$HOME/.aliases-git.sh"
        "$HOME/.color-tab.iterm.sh"
        "$HOME/.completion-git.sh"
        # Emacs configuration
        "$HOME/.config/emacs/init.el"
        "$HOME/.config/emacs/early-init.el"
        "$HOME/.config/emacs/config.org"
        "$HOME/.config/emacs/themes/zenburn-theme.el"
    )
    
    log "INFO" "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    for file in "${files_to_backup[@]}"; do
        if [[ -f "$file" || -L "$file" ]]; then
            log "INFO" "Backing up: $file"
            cp -L "$file" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    
    log "SUCCESS" "Backup created at: $BACKUP_DIR"
}

# Install system dependencies
install_system_deps() {
    local os="$1"
    
    log "INFO" "Installing system dependencies for $os"
    
    if [[ ! -f "$DOTFILES_DIR/install/${os}-install.sh" ]]; then
        log "WARNING" "No system installer found for $os"
        return 0
    fi
    
    bash "$DOTFILES_DIR/install/${os}-install.sh" || {
        log "ERROR" "Failed to install system dependencies"
        return 1
    }
    
    log "SUCCESS" "System dependencies installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log "INFO" "Oh My Zsh already installed"
        return 0
    fi
    
    log "INFO" "Installing Oh My Zsh"
    
    # Download and install Oh My Zsh
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
        error_exit "Failed to install Oh My Zsh"
    }
    
    log "SUCCESS" "Oh My Zsh installed"
}

# Install ZSH plugins
install_zsh_plugins() {
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "zsh-completions:https://github.com/zsh-users/zsh-completions"
        "zsh-docker-aliases:https://github.com/akarzim/zsh-docker-aliases.git"
    )
    
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    for plugin_info in "${plugins[@]}"; do
        local plugin_name="${plugin_info%%:*}"
        local plugin_url="${plugin_info##*:}"
        local plugin_dir="$custom_dir/$plugin_name"
        
        if [[ -d "$plugin_dir" ]]; then
            log "INFO" "Plugin $plugin_name already installed"
            continue
        fi
        
        log "INFO" "Installing plugin: $plugin_name"
        git clone "$plugin_url" "$plugin_dir" || {
            log "ERROR" "Failed to install plugin: $plugin_name"
            continue
        }
        
        log "SUCCESS" "Plugin installed: $plugin_name"
    done
}

# Create symlinks
create_symlinks() {
    local symlinks=(
        ".zshrc:$DOTFILES_DIR/.zshrc"
        ".aliases.sh:$DOTFILES_DIR/scripts/.aliases.sh"
        ".aliases-git.sh:$DOTFILES_DIR/scripts/.aliases-git.sh"
        ".aws.sh:$DOTFILES_DIR/scripts/.aws.sh"
        ".functions.sh:$DOTFILES_DIR/scripts/.functions.sh"
    )
    
    # Only create color-tab symlink if the file exists
    if [[ -f "$DOTFILES_DIR/scripts/.color-tab.iterm.sh" ]]; then
        symlinks+=(".color-tab.iterm.sh:$DOTFILES_DIR/scripts/.color-tab.iterm.sh")
    fi
    
    if [[ -f "$DOTFILES_DIR/scripts/.completion-git.sh" ]]; then
        symlinks+=(".completion-git.sh:$DOTFILES_DIR/scripts/.completion-git.sh")
    fi
    
    # Emacs configuration (only if it exists)
    if [[ -d "$DOTFILES_DIR/.config/emacs" ]]; then
        log "INFO" "Setting up Emacs configuration"
        
        # Create .config/emacs directory if it doesn't exist
        mkdir -p "$HOME/.config/emacs/themes"
        
        # Emacs symlinks
        if [[ -f "$DOTFILES_DIR/.config/emacs/init.el" ]]; then
            symlinks+=(".config/emacs/init.el:$DOTFILES_DIR/.config/emacs/init.el")
        fi
        
        if [[ -f "$DOTFILES_DIR/.config/emacs/early-init.el" ]]; then
            symlinks+=(".config/emacs/early-init.el:$DOTFILES_DIR/.config/emacs/early-init.el")
        fi
        
        if [[ -f "$DOTFILES_DIR/.config/emacs/config.org" ]]; then
            symlinks+=(".config/emacs/config.org:$DOTFILES_DIR/.config/emacs/config.org")
        fi
        
        if [[ -f "$DOTFILES_DIR/.config/emacs/themes/zenburn-theme.el" ]]; then
            symlinks+=(".config/emacs/themes/zenburn-theme.el:$DOTFILES_DIR/.config/emacs/themes/zenburn-theme.el")
        fi
    fi
    
    for symlink_info in "${symlinks[@]}"; do
        local target="${symlink_info%%:*}"
        local source="${symlink_info##*:}"
        local target_path="$HOME/$target"
        
        # Remove existing file/symlink
        if [[ -e "$target_path" || -L "$target_path" ]]; then
            rm -f "$target_path"
        fi
        
        # Create symlink
        if [[ -f "$source" ]]; then
            ln -s "$source" "$target_path"
            log "SUCCESS" "Created symlink: $target_path -> $source"
        else
            log "WARNING" "Source file not found: $source"
        fi
    done
}

# Set ZSH as default shell
set_default_shell() {
    local current_shell="$SHELL"
    local zsh_path
    
    # Find zsh path
    if command -v zsh >/dev/null 2>&1; then
        zsh_path="$(command -v zsh)"
    else
        error_exit "ZSH not found in PATH"
    fi
    
    if [[ "$current_shell" == "$zsh_path" ]]; then
        log "INFO" "ZSH is already the default shell"
        return 0
    fi
    
    log "INFO" "Setting ZSH as default shell"
    
    # Check if zsh is in /etc/shells
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        log "INFO" "Adding $zsh_path to /etc/shells"
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    
    # Change shell
    chsh -s "$zsh_path" || {
        log "ERROR" "Failed to change shell to ZSH"
        return 1
    }
    
    log "SUCCESS" "Default shell set to ZSH"
}

# Verify installation
verify_installation() {
    local errors=0
    
    log "INFO" "Verifying installation"
    
    # Check symlinks
    local expected_symlinks=(
        "$HOME/.zshrc"
        "$HOME/.aliases.sh"
        "$HOME/.aliases-git.sh"
    )
    
    # Add Emacs symlinks if they should exist
    if [[ -d "$DOTFILES_DIR/.config/emacs" ]]; then
        if [[ -f "$DOTFILES_DIR/.config/emacs/init.el" ]]; then
            expected_symlinks+=("$HOME/.config/emacs/init.el")
        fi
        if [[ -f "$DOTFILES_DIR/.config/emacs/early-init.el" ]]; then
            expected_symlinks+=("$HOME/.config/emacs/early-init.el")
        fi
        if [[ -f "$DOTFILES_DIR/.config/emacs/config.org" ]]; then
            expected_symlinks+=("$HOME/.config/emacs/config.org")
        fi
    fi
    
    for symlink in "${expected_symlinks[@]}"; do
        if [[ ! -L "$symlink" ]]; then
            log "ERROR" "Missing or invalid symlink: $symlink"
            ((errors++))
        fi
    done
    
    # Check ZSH plugins
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    local expected_plugins=("zsh-autosuggestions" "zsh-syntax-highlighting")
    
    for plugin in "${expected_plugins[@]}"; do
        if [[ ! -d "$plugin_dir/$plugin" ]]; then
            log "ERROR" "Missing ZSH plugin: $plugin"
            ((errors++))
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        log "SUCCESS" "Installation verified successfully"
        return 0
    else
        log "ERROR" "Installation verification failed with $errors errors"
        return 1
    fi
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -h, --help              Show this help message
    -n, --dry-run          Show what would be done without making changes
    -b, --backup-only      Only create backup, don't install
    -v, --verify-only      Only verify existing installation
    --skip-system-deps     Skip system dependency installation
    --skip-oh-my-zsh       Skip Oh My Zsh installation
    --skip-plugins         Skip ZSH plugin installation

EOF
}

# Main installation function
main() {
    local dry_run=false
    local backup_only=false
    local verify_only=false
    local skip_system_deps=false
    local skip_oh_my_zsh=false
    local skip_plugins=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -b|--backup-only)
                backup_only=true
                shift
                ;;
            -v|--verify-only)
                verify_only=true
                shift
                ;;
            --skip-system-deps)
                skip_system_deps=true
                shift
                ;;
            --skip-oh-my-zsh)
                skip_oh_my_zsh=true
                shift
                ;;
            --skip-plugins)
                skip_plugins=true
                shift
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Initialize log
    echo "# Dotfiles Installation Log - $(date)" > "$LOG_FILE"
    
    log "INFO" "Starting dotfiles installation"
    log "INFO" "Script directory: $SCRIPT_DIR"
    log "INFO" "Backup directory: $BACKUP_DIR"
    
    # Check prerequisites
    check_root
    
    # Detect OS
    local os
    os=$(detect_os)
    log "INFO" "Detected OS: $os"
    
    # Handle special modes
    if [[ "$verify_only" == true ]]; then
        verify_installation
        exit $?
    fi
    
    if [[ "$backup_only" == true ]]; then
        create_backup
        exit 0
    fi
    
    if [[ "$dry_run" == true ]]; then
        log "INFO" "DRY RUN MODE - No changes will be made"
        # Add dry run logic here
        exit 0
    fi
    
    # Create backup
    create_backup
    
    # Install system dependencies
    if [[ "$skip_system_deps" != true ]]; then
        install_system_deps "$os"
    fi
    
    # Install Oh My Zsh
    if [[ "$skip_oh_my_zsh" != true ]]; then
        install_oh_my_zsh
    fi
    
    # Install ZSH plugins
    if [[ "$skip_plugins" != true ]]; then
        install_zsh_plugins
    fi
    
    # Create symlinks
    create_symlinks
    
    # Set default shell
    set_default_shell
    
    # Verify installation
    verify_installation
    
    log "SUCCESS" "Installation completed successfully!"
    log "INFO" "Backup created at: $BACKUP_DIR"
    log "INFO" "Log file: $LOG_FILE"
    
    echo
    echo -e "${GREEN}🎉 Dotfiles installation completed!${NC}"
    echo -e "${BLUE}📝 Please restart your terminal or run: ${YELLOW}exec zsh${NC}"
    echo -e "${BLUE}📋 Backup created at: ${YELLOW}$BACKUP_DIR${NC}"
    echo -e "${BLUE}📄 Installation log: ${YELLOW}$LOG_FILE${NC}"
}

# Run main function
main "$@"