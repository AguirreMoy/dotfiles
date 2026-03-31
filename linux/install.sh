#!/bin/sh

# This script handles all tool installation and setup for Linux.

set -e

TOOLS_TO_INSTALL="tldr neovim tmux lsd ripgrep fd-find bat zoxide fzf curl unzip"
PKG_MANAGER="sudo apt-get install -y"
SELECTED_SHELL="${DOTFILES_SHELL:-zsh}"

log_info() { printf "\033[0;34m[INFO]\033[0m %s\n" "$1"; }
log_success() { printf "\033[0;32m[SUCCESS]\033[0m %s\n" "$1"; }
log_warn() { printf "\033[0;33m[WARNING]\033[0m %s\n" "$1"; }
log_error() { printf "\033[0;31m[ERROR]\033[0m %s\n" "$1" >&2; exit 1; }

require_supported_shell() {
    case "$SELECTED_SHELL" in
        fish|zsh) ;;
        *) log_error "Unsupported shell selection: $SELECTED_SHELL" ;;
    esac
}

ensure_local_bin() {
    mkdir -p "$HOME/.local/bin"
}

install_sheldon() {
    if command -v sheldon >/dev/null 2>&1; then
        log_info "sheldon is already installed. Skipping."
        return
    fi

    ensure_local_bin
    log_info "Installing sheldon..."
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to "$HOME/.local/bin"
    log_success "sheldon installed."
}

install_zsh_patina() {
    if command -v zsh-patina >/dev/null 2>&1; then
        log_info "zsh-patina is already installed. Skipping."
        return
    fi

    ensure_local_bin
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64) target="x86_64-unknown-linux-gnu" ;;
        aarch64|arm64) target="aarch64-unknown-linux-gnu" ;;
        armv7l|armv7) target="arm-unknown-linux-gnueabihf" ;;
        i686|i386) target="i686-unknown-linux-gnu" ;;
        *) log_error "Unsupported architecture for zsh-patina: $arch" ;;
    esac

    version=$(curl -fsSL https://api.github.com/repos/michel-kraemer/zsh-patina/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')
    asset="zsh-patina-v${version}-${target}.tar.gz"
    temp_dir=$(mktemp -d)

    log_info "Installing zsh-patina..."
    curl -fsSL "https://github.com/michel-kraemer/zsh-patina/releases/download/${version}/${asset}" -o "$temp_dir/$asset"
    tar -xzf "$temp_dir/$asset" -C "$temp_dir"
    install "$temp_dir/zsh-patina" "$HOME/.local/bin/zsh-patina"
    rm -rf "$temp_dir"
    log_success "zsh-patina installed."
}

install_fish_tooling() {
    if ! command -v fish >/dev/null 2>&1; then
        log_warn "Fish shell not found. Skipping Fisher installation."
        return
    fi

    if ! fish -c "type -q fisher" >/dev/null 2>&1; then
        log_info "Installing Fisher..."
        fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
        log_success "Fisher installed."
    else
        log_info "Fisher is already installed."
    fi

    log_info "Installing/Updating nvm.fish..."
    fish -c "fisher install jorgebucaran/nvm.fish"
    log_info "Setting default Node.js version to lts..."
    fish -c "set -U nvm_default_version lts"
    log_success "Fisher plugins and configuration updated."
}

install_ghostty() {
    if command -v ghostty >/dev/null 2>&1; then
        log_info "Ghostty is already installed. Skipping."
        return
    fi

    if apt-cache show ghostty >/dev/null 2>&1; then
        log_info "Installing Ghostty..."
        $PKG_MANAGER ghostty
        log_success "Ghostty installed."
    else
        log_warn "Ghostty package not available via apt on this system. Skipping Ghostty installation."
    fi
}


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

    case "$SELECTED_SHELL" in
        fish)
            if ! command -v fish >/dev/null 2>&1; then
                log_info "Installing fish..."
                $PKG_MANAGER fish
            fi
            install_fish_tooling
            ;;
        zsh)
            if ! command -v zsh >/dev/null 2>&1; then
                log_info "Installing zsh..."
                $PKG_MANAGER zsh
            fi
            install_sheldon
            install_zsh_patina
            ;;
    esac

    log_success "CLI tool installation complete."
}

# --- Main Execution ---
require_supported_shell
install_tools
install_ghostty
# Check if Starship is already installed
if ! command -v starship >/dev/null 2>&1; then
    log_info "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh
    log_success "Starship installed."
else
    log_info "Starship is already installed. Skipping."
fi

# Manually build and install hellwal.
log_info "Building and installing hellwal..."
if ! command -v git >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1; then
    log_info "Installing git and make for hellwal build..."
    sudo apt-get install -y git make
fi

if [ -d "hellwal" ]; then
    log_warn "hellwal directory already exists. Skipping git clone."
else
    git clone https://github.com/danihek/hellwal
fi

cd hellwal && make
log_success "hellwal built and installed."

# Remove hellwal artifacts after installation
log_info "Removing hellwal build artifacts..."
cd ..
rm -rf hellwal

install_victormono_nerd_font() {
    log_info "Installing VictorMono Nerd Font..."
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    TEMP_DIR=$(mktemp -d)
    curl -L -o "$TEMP_DIR/VictorMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/VictorMono.zip
    unzip "$TEMP_DIR/VictorMono.zip" -d "$TEMP_DIR"
    mv "$TEMP_DIR"/*.ttf "$FONT_DIR/"
    rm -rf "$TEMP_DIR"
    fc-cache -fv
    log_success "VictorMono Nerd Font installed."
}

install_victormono_nerd_font
