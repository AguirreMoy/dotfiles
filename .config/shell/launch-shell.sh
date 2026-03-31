#!/bin/sh

ACTIVE_SHELL_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/shell/active-shell"

if [ -n "${DOTFILES_SHELL:-}" ]; then
    selected_shell=$DOTFILES_SHELL
elif [ -f "$ACTIVE_SHELL_FILE" ]; then
    selected_shell=$(tr -d '[:space:]' < "$ACTIVE_SHELL_FILE")
else
    selected_shell=${SHELL##*/}
fi

case "$selected_shell" in
    fish|zsh|bash) ;;
    *) selected_shell=${SHELL##*/} ;;
esac

shell_path=$(command -v "$selected_shell" 2>/dev/null || true)
if [ -z "$shell_path" ]; then
    shell_path=${SHELL:-/bin/sh}
fi

unset DOTFILES_ZSHRC_LOADED
unset DOTFILES_GREETING_SHOWN

case "$selected_shell" in
    fish|zsh|bash)
        exec "$shell_path" -i -l
        ;;
    *)
        exec "$shell_path"
        ;;
esac
