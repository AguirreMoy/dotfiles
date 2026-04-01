#!/bin/sh

# This script handles all tool installation and setup for macOS.

set -e

TOOLS_TO_INSTALL="neovim tmux lsd ripgrep fd bat zoxide fzf hellwal curl unzip"
PKG_MANAGER="brew install"
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

install_zsh_tooling() {
    if ! command -v sheldon >/dev/null 2>&1; then
        log_info "Installing sheldon..."
        brew install sheldon
    else
        log_info "sheldon is already installed. Skipping."
    fi

    if ! command -v zsh-patina >/dev/null 2>&1; then
        log_info "Installing zsh-patina..."
        brew tap michel-kraemer/zsh-patina
        brew install zsh-patina
    else
        log_info "zsh-patina is already installed. Skipping."
    fi
}

install_ghostty() {
    if command -v ghostty >/dev/null 2>&1; then
        log_info "Ghostty is already installed. Skipping."
        return
    fi

    log_info "Installing Ghostty..."
    brew install --cask ghostty
    log_success "Ghostty installed."
}

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
            log_info "$tool is already installed. Skipping."
        fi
    done

    case "$SELECTED_SHELL" in
        fish)
            if ! command -v fish >/dev/null 2>&1; then
                log_info "Installing fish..."
                brew install fish
            fi
            install_fish_tooling
            ;;
        zsh)
            if ! command -v zsh >/dev/null 2>&1; then
                log_info "Installing zsh..."
                brew install zsh
            fi
            install_zsh_tooling
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

install_victormono_nerd_font() {
    log_info "Installing VictorMono Nerd Font..."
    FONT_DIR="$HOME/Library/Fonts"
    TEMP_DIR=$(mktemp -d)
    curl -L -o "$TEMP_DIR/VictorMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/VictorMono.zip
    unzip "$TEMP_DIR/VictorMono.zip" -d "$TEMP_DIR"
    mv "$TEMP_DIR"/*.ttf "$FONT_DIR/"
    rm -rf "$TEMP_DIR"
    log_success "VictorMono Nerd Font installed."
}

install_victormono_nerd_font
