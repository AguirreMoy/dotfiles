#!/bin/sh

# This script handles all tool installation and setup for Linux.

set -e

TOOLS_TO_INSTALL="tldr neovim lsd ripgrep fd-find bat zoxide fzf hellwal"
PKG_MANAGER="sudo apt-get install -y"

log_info() { printf "\033[0;34m[INFO]\033[0m %s\n" "$1"; }
log_success() { printf "\033[0;32m[SUCCESS]\033[0m %s\n" "$1"; }
log_warn() { printf "\033[0;33m[WARNING]\033[0m %s\n" "$1"; }
log_error() { printf "\033[0;31m[ERROR]\033[0m %s\n" "$1" >&2; exit 1; }


install_vscode_linux() {
    log_info "Installing VS Code (Linux)..."
    if ! command -v wget >/dev/null 2>&1 || ! command -v gpg >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y wget gpg
    fi
    log_info "Adding Microsoft apt repository..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm packages.microsoft.gpg
    sudo apt-get update
    sudo apt-get install -y code
    log_success "VS Code installed."
}


install_tools() {
    log_info "Starting installation of CLI tools..."
    sudo apt-get update
    if ! command -v code >/dev/null 2>&1; then install_vscode_linux; fi
    for tool in $TOOLS_TO_INSTALL; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_info "Installing $tool..."; $PKG_MANAGER "$tool"
        else
            log_info "$tool is already installed. Skipping."
        fi
    done
    log_success "CLI tool installation complete."
}

# --- Main Execution ---
install_tools
# Check if Starship is already installed
if ! command -v starship >/dev/null 2>&1; then
    log_info "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh
    log_success "Starship installed."
else
    log_info "Starship is already installed. Skipping."
fi
