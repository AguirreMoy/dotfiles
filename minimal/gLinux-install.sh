#!/bin/sh

# This script handles all tool installation and setup for Google Linux (cloudtop).

set -e

TOOLS_TO_INSTALL="tmux zoxide curl unzip atuin"
PKG_MANAGER="sudo apt-get install -y"

log_info() { printf "\033[0;34m[INFO]\033[0m %s\n" "$1"; }
log_success() { printf "\033[0;32m[SUCCESS]\033[0m %s\n" "$1"; }
log_warn() { printf "\033[0;33m[WARNING]\033[0m %s\n" "$1"; }

ask_install() {
    local package="$1"
    while true; do
        printf "Do you want to install %s? [y/N] " "$package"
        read -r yn
        case $yn in
            [Yy]* ) return 0;;
            * ) return 1;;
        esac
    done
}

install_ghostty() {
    if command -v ghostty >/dev/null 2>&1; then
        log_info "Ghostty is already installed. Skipping."
        return
    fi

    if ask_install "Ghostty"; then
        if apt-cache show ghostty >/dev/null 2>&1; then
            log_info "Installing Ghostty..."
            $PKG_MANAGER ghostty
            log_success "Ghostty installed."
        else
            log_warn "Ghostty package not available via apt on this system. Skipping Ghostty installation."
        fi
    fi
}

install_tools() {
    log_info "Starting installation of CLI tools..."
    sudo apt-get update
    
    for tool in $TOOLS_TO_INSTALL; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            if ask_install "$tool"; then
                log_info "Installing $tool..."; $PKG_MANAGER "$tool"
            fi
        else
            log_info "$tool is already installed. Skipping."
        fi
    done

    log_success "CLI tool installation complete."
}

# --- Main Execution ---
install_tools
install_ghostty

# Check if Starship is already installed
if ! command -v starship >/dev/null 2>&1; then
    if ask_install "Starship"; then
        log_info "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh
        log_success "Starship installed."
    fi
else
    log_info "Starship is already installed. Skipping."
fi
