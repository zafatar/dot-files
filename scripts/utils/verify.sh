#!/bin/bash
set -euo pipefail

# Dotfiles Verification Utility
# ==============================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

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
Usage: $0 [OPTIONS]

Verify dotfiles installation and configuration.

Options:
    -h, --help          Show this help message
    -v, --verbose       Show detailed information
    -f, --fix           Attempt to fix common issues
    --check-links       Only check symlinks
    --check-plugins     Only check ZSH plugins
    --check-shell       Only check shell configuration

Examples:
    $0                  # Run all checks
    $0 --verbose        # Run all checks with detailed output
    $0 --check-links    # Only verify symlinks
    $0 --fix            # Run checks and fix issues

EOF
}

check_symlinks() {
    local verbose="$1"
    local fix="$2"
    local errors=0
    
    log "INFO" "Checking symlinks..."
    
    local expected_symlinks=(
        "$HOME/.zshrc:$DOTFILES_DIR/.zshrc"
        "$HOME/.aliases.sh:$DOTFILES_DIR/scripts/.aliases.sh" 
        "$HOME/.aliases-git.sh:$DOTFILES_DIR/scripts/.aliases-git.sh"
    )
    
    # Optional symlinks (only check if source exists)
    if [[ -f "$DOTFILES_DIR/scripts/.color-tab.iterm.sh" ]]; then
        expected_symlinks+=("$HOME/.color-tab.iterm.sh:$DOTFILES_DIR/scripts/.color-tab.iterm.sh")
    fi
    
    if [[ -f "$DOTFILES_DIR/scripts/.completion-git.sh" ]]; then
        expected_symlinks+=("$HOME/.completion-git.sh:$DOTFILES_DIR/scripts/.completion-git.sh")
    fi
    
    for symlink_info in "${expected_symlinks[@]}"; do
        local target="${symlink_info%%:*}"
        local expected_source="${symlink_info##*:}"
        
        if [[ -L "$target" ]]; then
            local actual_source="$(readlink "$target")"
            if [[ "$actual_source" == "$expected_source" ]]; then
                if [[ "$verbose" == true ]]; then
                    log "SUCCESS" "Symlink OK: $target -> $actual_source"
                fi
            else
                log "ERROR" "Symlink mismatch: $target -> $actual_source (expected: $expected_source)"
                ((errors++))
                
                if [[ "$fix" == true ]]; then
                    log "INFO" "Fixing symlink: $target"
                    rm -f "$target"
                    ln -s "$expected_source" "$target"
                    log "SUCCESS" "Fixed symlink: $target"
                fi
            fi
        elif [[ -f "$target" ]]; then
            log "WARNING" "Regular file instead of symlink: $target"
            if [[ "$fix" == true ]]; then
                log "INFO" "Converting to symlink: $target"
                rm -f "$target"
                ln -s "$expected_source" "$target"
                log "SUCCESS" "Converted to symlink: $target"
            fi
        else
            log "ERROR" "Missing symlink: $target"
            ((errors++))
            
            if [[ "$fix" == true ]]; then
                log "INFO" "Creating symlink: $target"
                ln -s "$expected_source" "$target"
                log "SUCCESS" "Created symlink: $target"
            fi
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        log "SUCCESS" "All symlinks are correct"
    else
        log "ERROR" "Found $errors symlink issues"
    fi
    
    return $errors
}

check_zsh_plugins() {
    local verbose="$1"
    local fix="$2"
    local errors=0
    
    log "INFO" "Checking ZSH plugins..."
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "ERROR" "Oh My Zsh not installed"
        ((errors++))
        return $errors
    fi
    
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    local expected_plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "zsh-completions:https://github.com/zsh-users/zsh-completions"
        "zsh-docker-aliases:https://github.com/akarzim/zsh-docker-aliases.git"
    )
    
    for plugin_info in "${expected_plugins[@]}"; do
        local plugin_name="${plugin_info%%:*}"
        local plugin_url="${plugin_info##*:}"
        local plugin_path="$plugin_dir/$plugin_name"
        
        if [[ -d "$plugin_path" ]]; then
            if [[ "$verbose" == true ]]; then
                log "SUCCESS" "Plugin installed: $plugin_name"
            fi
        else
            log "ERROR" "Missing plugin: $plugin_name"
            ((errors++))
            
            if [[ "$fix" == true ]]; then
                log "INFO" "Installing plugin: $plugin_name"
                git clone "$plugin_url" "$plugin_path" || {
                    log "ERROR" "Failed to install plugin: $plugin_name"
                    continue
                }
                log "SUCCESS" "Installed plugin: $plugin_name"
            fi
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        log "SUCCESS" "All ZSH plugins are installed"
    else
        log "ERROR" "Found $errors plugin issues"
    fi
    
    return $errors
}

check_shell_config() {
    local verbose="$1"
    local errors=0
    
    log "INFO" "Checking shell configuration..."
    
    # Check current shell
    if [[ "$SHELL" =~ zsh ]]; then
        if [[ "$verbose" == true ]]; then
            log "SUCCESS" "Default shell is ZSH: $SHELL"
        fi
    else
        log "WARNING" "Default shell is not ZSH: $SHELL"
    fi
    
    # Check ZSH version
    if command -v zsh >/dev/null 2>&1; then
        local zsh_version="$(zsh --version)"
        if [[ "$verbose" == true ]]; then
            log "INFO" "ZSH version: $zsh_version"
        fi
    else
        log "ERROR" "ZSH not found in PATH"
        ((errors++))
    fi
    
    # Check .zshrc syntax
    if [[ -f "$HOME/.zshrc" ]]; then
        if zsh -n "$HOME/.zshrc" 2>/dev/null; then
            if [[ "$verbose" == true ]]; then
                log "SUCCESS" ".zshrc syntax is valid"
            fi
        else
            log "ERROR" ".zshrc has syntax errors"
            ((errors++))
        fi
    else
        log "ERROR" ".zshrc not found"
        ((errors++))
    fi
    
    # Check for common issues in .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        # Check if Oh My Zsh is sourced
        if grep -q "source.*oh-my-zsh.sh" "$HOME/.zshrc"; then
            if [[ "$verbose" == true ]]; then
                log "SUCCESS" "Oh My Zsh is sourced in .zshrc"
            fi
        else
            log "WARNING" "Oh My Zsh not sourced in .zshrc"
        fi
        
        # Check if plugins are defined
        if grep -q "plugins=" "$HOME/.zshrc"; then
            if [[ "$verbose" == true ]]; then
                local plugins_line="$(grep "plugins=" "$HOME/.zshrc" | head -1)"
                log "INFO" "Plugins configured: $plugins_line"
            fi
        else
            log "WARNING" "No plugins configured in .zshrc"
        fi
    fi
    
    if [[ $errors -eq 0 ]]; then
        log "SUCCESS" "Shell configuration looks good"
    else
        log "ERROR" "Found $errors shell configuration issues"
    fi
    
    return $errors
}

check_file_permissions() {
    local verbose="$1"
    local errors=0
    
    log "INFO" "Checking file permissions..."
    
    local files_to_check=(
        "$HOME/.zshrc"
        "$HOME/.aliases.sh"
        "$HOME/.aliases-git.sh"
    )
    
    for file in "${files_to_check[@]}"; do
        if [[ -f "$file" ]]; then
            local perms="$(stat -c %a "$file" 2>/dev/null || stat -f %A "$file" 2>/dev/null || echo "unknown")"
            if [[ "$perms" == "644" || "$perms" == "600" ]]; then
                if [[ "$verbose" == true ]]; then
                    log "SUCCESS" "Permissions OK: $file ($perms)"
                fi
            else
                log "WARNING" "Unusual permissions: $file ($perms)"
            fi
        fi
    done
    
    return $errors
}

run_all_checks() {
    local verbose="$1"
    local fix="$2"
    local check_links="$3"
    local check_plugins="$4"
    local check_shell="$5"
    
    local total_errors=0
    
    echo "🔍 Dotfiles Verification Report"
    echo "==============================="
    echo
    
    if [[ "$check_links" == true || "$check_links" == "all" ]]; then
        check_symlinks "$verbose" "$fix"
        total_errors=$((total_errors + $?))
        echo
    fi
    
    if [[ "$check_plugins" == true || "$check_plugins" == "all" ]]; then
        check_zsh_plugins "$verbose" "$fix"
        total_errors=$((total_errors + $?))
        echo
    fi
    
    if [[ "$check_shell" == true || "$check_shell" == "all" ]]; then
        check_shell_config "$verbose"
        total_errors=$((total_errors + $?))
        echo
    fi
    
    if [[ "$check_links" == "all" ]]; then
        check_file_permissions "$verbose"
        total_errors=$((total_errors + $?))
        echo
    fi
    
    echo "==============================="
    if [[ $total_errors -eq 0 ]]; then
        log "SUCCESS" "All checks passed! ✨"
    else
        log "ERROR" "Found $total_errors total issues"
        if [[ "$fix" != true ]]; then
            echo -e "${YELLOW}💡 Run with --fix to attempt automatic repairs${NC}"
        fi
    fi
    
    return $total_errors
}

main() {
    local verbose=false
    local fix=false
    local check_links="all"
    local check_plugins="all"
    local check_shell="all"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -f|--fix)
                fix=true
                shift
                ;;
            --check-links)
                check_links=true
                check_plugins=false
                check_shell=false
                shift
                ;;
            --check-plugins)
                check_links=false
                check_plugins=true
                check_shell=false
                shift
                ;;
            --check-shell)
                check_links=false
                check_plugins=false
                check_shell=true
                shift
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    run_all_checks "$verbose" "$fix" "$check_links" "$check_plugins" "$check_shell"
}

main "$@" 