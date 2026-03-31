#!/usr/bin/env bash

# This is the main entry point for synchronizing dotfiles.
# It detects the OS and calls the appropriate installation script.

set -euo pipefail

# --- Configuration ---
# The directories and files to symlink.
DOTFILES_TO_SYNC=(
    ".config/nvim:.config/nvim"
    ".config/fish:.config/fish"
    ".config/shell/common.sh:.config/shell/common.sh"
    ".config/shell/launch-shell.sh:.config/shell/launch-shell.sh"
    ".config/sheldon:.config/sheldon"
    ".config/zsh:.config/zsh"
    ".config/zsh-abbr:.config/zsh-abbr"
    ".config/tmux:.config/tmux"
    ".config/starship.toml:.config/starship.toml"
    ".config/ghostty:.config/ghostty"
    ".config/kitty:.config/kitty"
    ".config/hellwal:.config/hellwal"
    ".cache/hellwal:.cache/hellwal"
    ".gitconfig:.gitconfig"
    ".zprofile:.zprofile"
    ".zshrc:.zshrc"
    ".paths:.paths"
    ".envs:.envs"
)

# --- Script Logic ---

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"

# --- Logging Functions ---
log_info() { printf "\033[0;34m[INFO]\033[0m %s\n" "$1"; }
log_success() { printf "\033[0;32m[SUCCESS]\033[0m %s\n" "$1"; }
log_warn() { printf "\033[0;33m[WARNING]\033[0m %s\n" "$1"; }
log_error() { printf "\033[0;31m[ERROR]\033[0m %s\n" "$1" >&2; exit 1; }

prompt_for_selection() {
    local prompt_message="$1"
    local first_option="$2"
    local second_option="$3"
    local choice

    while true; do
        log_warn "$prompt_message" >&2
        printf "1) %s\n2) %s\nSelection: " "$first_option" "$second_option" >&2
        read -r choice
        case "$choice" in
            1) printf '%s\n' "$first_option"; return 0 ;;
            2) printf '%s\n' "$second_option"; return 0 ;;
            *) log_warn "Invalid selection. Please try again." >&2 ;;
        esac
    done
}

resolve_selected_shell() {
    case "${DOTFILES_SHELL:-}" in
        fish|zsh)
            printf '%s\n' "$DOTFILES_SHELL"
            ;;
        "")
            prompt_for_selection "Which shell tooling should this install prepare?" "zsh" "fish"
            ;;
        *)
            log_error "Invalid DOTFILES_SHELL value: ${DOTFILES_SHELL:-}. Must be 'zsh' or 'fish'."
            ;;
    esac
}

# --- Environment Check & Gitconfig Setup ---
if [ -z "${MY_ENV:-}" ]; then
    MY_ENV=$(prompt_for_selection "MY_ENV not set. Please choose your environment:" "personal" "work")
    log_success "MY_ENV set to '$MY_ENV' for this session."
    log_info "Note: To make this permanent, export MY_ENV in your shell's config file."
fi

log_info "Environment detected: ${MY_ENV:-}"
SELECTED_SHELL=$(resolve_selected_shell)
export DOTFILES_SHELL="$SELECTED_SHELL"
log_info "Preparing shell tooling for: $SELECTED_SHELL"
mkdir -p "$HOME_DIR/.config/shell"
printf '%s\n' "$SELECTED_SHELL" > "$HOME_DIR/.config/shell/active-shell"
ENVIRONMENT_CONFIG="$HOME/.gitconfig.environment"
ENVIRONMENT_ENVS="$HOME/.envs.environment"
ENVIRONMENT_PATHS="$HOME/.paths.environment"

# Remove existing symlink or file
rm -f "$ENVIRONMENT_CONFIG"
rm -f "$ENVIRONMENT_ENVS"
rm -f "$ENVIRONMENT_PATHS"

case "${MY_ENV:-}" in
    personal)
        ln -s "$SCRIPT_DIR/.gitconfig.personal" "$ENVIRONMENT_CONFIG"
        ln -s "$SCRIPT_DIR/.envs.personal" "$ENVIRONMENT_ENVS"
        ln -s "$SCRIPT_DIR/.paths.personal" "$ENVIRONMENT_PATHS"
        log_success "Linked .gitconfig.environment -> .gitconfig.personal"
        log_success "Linked .envs.environment -> .envs.personal"
        log_success "Linked .paths.environment -> .paths.personal"
        ;;
    work)
        ln -s "$SCRIPT_DIR/.gitconfig.work" "$ENVIRONMENT_CONFIG"
        ln -s "$SCRIPT_DIR/.envs.work" "$ENVIRONMENT_ENVS"
        ln -s "$SCRIPT_DIR/.paths.work" "$ENVIRONMENT_PATHS"
        log_success "Linked .gitconfig.environment -> .gitconfig.work"
        log_success "Linked .envs.environment -> .envs.work"
        log_success "Linked .paths.environment -> .paths.work"
        ;;
    *)
        log_error "Invalid MY_ENV value: ${MY_ENV:-}. Must be 'personal' or 'work'."
        ;;
esac


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
        #Check if exenstion already installed, if so skip
        if code --list-extensions | grep -q "^$ext$"; then
            log_info "  $ext is already installed. Skipping."
            continue
        fi
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

if [ -d "$(dirname "$HOME_DIR/$VSC_SETTINGS_FILE")" ]; then
    install_vscode_extensions "$SCRIPT_DIR/vscode/extensions.txt"
fi

# --- Shell Plugin Sync ---
if [ "$SELECTED_SHELL" = "fish" ] && command -v fish >/dev/null 2>&1; then
    log_info "Updating Fisher plugins..."
    fish -c "fisher update"
    log_success "Fisher plugins updated."
fi

if [ "$SELECTED_SHELL" = "zsh" ] && command -v sheldon >/dev/null 2>&1; then
    log_info "Syncing Sheldon plugins..."
    sheldon source >/dev/null
    log_success "Sheldon plugins synced."
fi
log_success "Dotfile synchronization complete."
log_warn "Please remember to manually install your paid fonts from your private repository."
