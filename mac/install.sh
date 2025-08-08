#!/bin/sh

# This script handles all tool installation and setup for macOS.

set -e

TOOLS_TO_INSTALL="neovim lsd ripgrep fd bat zoxide fzf hellwal"
PKG_MANAGER="brew install"

log_info() { printf "\033[0;34m[INFO]\033[0m %s\n" "$1"; }
log_success() { printf "\033[0;32m[SUCCESS]\033[0m %s\n" "$1"; }
log_warn() { printf "\033[0;33m[WARNING]\033[0m %s\n" "$1"; }
log_error() { printf "\033[0;31m[ERROR]\033[0m %s\n" "$1" >&2; exit 1; }

install_tools() {
    log_info "Starting installation of CLI tools..."
    if ! command -v brew >/dev/null 2>&1; then
        log_info "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        log_success "Homebrew installed."
    fi
    if ! command -v code >/dev/null 2>&1; then
        log_info "Installing VS Code (macOS)..."; brew install --cask visual-studio-code
        log_success "VS Code installed."
    fi
    for tool in $TOOLS_TO_INSTALL; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_info "Installing $tool..."; $PKG_MANAGER "$tool"
        else
            log_warn "$tool is already installed. Skipping."
        fi
    done
    log_success "CLI tool installation complete."
}


# --- Main Execution ---
install_tools
