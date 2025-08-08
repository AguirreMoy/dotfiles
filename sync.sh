#!/bin/sh

# This is the main entry point for synchronizing dotfiles.
# It detects the OS and calls the appropriate installation script.

set -e

# --- Configuration ---
# The directories and files to symlink.
DOTFILES_TO_SYNC=(
    ".config/nvim:.config/nvim"
    ".config/fish:.config/fish"
    ".config/starship.toml:.config/starship.toml"
    ".config/kitty:.config/kitty"
    ".config/hellwal:.config/hellwal"
    ".cache/hellwal:.cache/hellwal"
    ".gitconfig:.gitconfig"
    ".paths:.paths"
)

# --- Script Logic ---

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"

# --- Logging Functions ---
log_info() { printf "\033[0;34m[INFO]\033[0m %s\n" "$1"; }
log_success() { printf "\033[0;32m[SUCCESS]\033[0m %s\n" "$1"; }
log_warn() { printf "\033[0;33m[WARNING]\033[0m %s\n" "$1"; }
log_error() { printf "\033[0;31m[ERROR]\033[0m %s\n" "$1" >&2; exit 1; }

# --- OS Detection and Sub-script Call ---
OS_NAME=$(uname -s)

if [ "$OS_NAME" = "Linux" ]; then
    log_info "Detected OS: Linux. Running Linux-specific setup..."
    VSC_SETTINGS_FILE=".config/Code/User/settings.json"
    "$SCRIPT_DIR/linux/install.sh"
elif [ "$OS_NAME" = "Darwin" ]; then
    log_info "Detected OS: macOS. Running macOS-specific setup..."
    VSC_SETTINGS_FILE="Library/Application Support/Code/User/settings.json"
    "$SCRIPT_DIR/mac/install.sh"
else
    log_error "Unsupported OS: $OS_NAME"
fi

# Add VS Code to the sync array now that we have the path
DOTFILES_TO_SYNC+=("vscode/settings.json:$VSC_SETTINGS_FILE")

# --- Symlink and Extension Management Functions ---
create_symlink() {
    local src="$1"
    local dest="$2"
    if [ ! -e "$src" ]; then log_warn "Source not found: $src"; return; fi
    mkdir -p "$(dirname "$dest")"
    if [ -e "$dest" ]; then
        if [ -L "$dest" ]; then rm "$dest"; else mv "$dest" "$dest.bak-$(date +%Y%m%d%H%M%S)"; fi
    fi
    ln -s "$src" "$dest"
    log_success "Symlinked $src -> $dest"
}

install_vscode_extensions() {
    local extension_file="$1"
    if [ ! -f "$extension_file" ]; then log_warn "VS Code extension list not found. Skipping."; return; fi
    log_info "Installing VS Code extensions..."
    if ! command -v code >/dev/null 2>&1; then log_warn "'code' command not found. Skipping."; return; fi
    while read -r ext; do
        if [ -n "$ext" ]; then log_info "  Installing $ext"; code --install-extension "$ext" || true; fi
    done < "$extension_file"
    log_success "VS Code extensions installation complete."
}

# --- Main Execution ---
log_info "Starting dotfile symlink synchronization..."
for item in "${DOTFILES_TO_SYNC[@]}"; do
    IFS=: read -r source_path target_path <<EOF
$item
EOF
    create_symlink "$SCRIPT_DIR/$source_path" "$HOME_DIR/$target_path"
done

if [ -d "$HOME_DIR/$VSC_CONFIG_DIR" ]; then
    install_vscode_extensions "$SCRIPT_DIR/vscode/extensions.txt"
fi

log_success "Dotfile synchronization complete."
log_warn "Please remember to manually install your paid fonts from your private repository."