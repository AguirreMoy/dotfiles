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

# --- Environment Check & Gitconfig Setup ---
if [ -z "$MY_ENV" ]; then
    log_warn "MY_ENV not set. Please choose your environment:"
    printf "1) Personal\n2) Work\n"
    printf "Selection: "
    read -r choice
    case "$choice" in
        1) MY_ENV="personal" ;;
        2) MY_ENV="work" ;;
        *) log_error "Invalid selection. Please run the script again and select 1 or 2." ;;
    esac
    log_success "MY_ENV set to '$MY_ENV' for this session."
    log_info "Note: To make this permanent, export MY_ENV in your shell's config file."
fi

log_info "Environment detected: $MY_ENV"
ENVIRONMENT_CONFIG="$HOME/.gitconfig.environment"
ENVIRONMENT_ENVS="$HOME/.envs.environment"
ENVIRONMENT_PATHS="$HOME/.paths.environment"

# Remove existing symlink or file
rm -f "$ENVIRONMENT_CONFIG"
rm -f "$ENVIRONMENT_ENVS"
rm -f "$ENVIRONMENT_PATHS"

case "$MY_ENV" in
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
        log_error "Invalid MY_ENV value: $MY_ENV. Must be 'personal' or 'work'."
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

if [ -d "$HOME_DIR/$VSC_CONFIG_DIR" ]; then
    install_vscode_extensions "$SCRIPT_DIR/vscode/extensions.txt"
fi

# --- Awesome Copilot Sync ---
log_info "Synchronizing Awesome Copilot..."
AWESOME_COPILOT_DIR="$SCRIPT_DIR/awesome-copilot"
COPILOT_CONFIG_DIR="$HOME_DIR/.copilot"

if [ ! -d "$AWESOME_COPILOT_DIR" ]; then
    log_info "Cloning Awesome Copilot repository..."
    git clone https://github.com/github/awesome-copilot.git "$AWESOME_COPILOT_DIR"
else
    log_info "Updating Awesome Copilot repository..."
    git -C "$AWESOME_COPILOT_DIR" pull
fi

mkdir -p "$COPILOT_CONFIG_DIR"

# Copy directories, overwriting existing files
for dir in agents instructions prompts skills collections; do
    if [ -d "$AWESOME_COPILOT_DIR/$dir" ]; then
        log_info "  Syncing $dir..."
        mkdir -p "$COPILOT_CONFIG_DIR/$dir"
        # Copy contents, overwriting existing files but preserving custom ones
        cp -R "$AWESOME_COPILOT_DIR/$dir/"* "$COPILOT_CONFIG_DIR/$dir/" 2>/dev/null || true
    fi
done
log_success "Awesome Copilot synchronization complete."

log_success "Dotfile synchronization complete."
log_warn "Please remember to manually install your paid fonts from your private repository."
