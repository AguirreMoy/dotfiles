#!/bin/sh
# Minimal dotfiles setup

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[INFO] Symlinking minimal configuration..."
ln -sf "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf"
ln -sf "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
echo "[SUCCESS] Symlinks created."

OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Linux" ]; then
    echo "[INFO] Detected Linux. Running gLinux-install.sh..."
    "$SCRIPT_DIR/gLinux-install.sh"
elif [ "$OS_NAME" = "Darwin" ]; then
    echo "[INFO] Detected macOS. Running gMac-install.sh..."
    "$SCRIPT_DIR/gMac-install.sh"
else
    echo "[WARNING] Unsupported OS: $OS_NAME"
fi
