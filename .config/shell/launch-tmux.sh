#!/bin/sh

SHELL_LAUNCHER="${XDG_CONFIG_HOME:-$HOME/.config}/shell/launch-shell.sh"
TMUX_SESSION="${DOTFILES_TMUX_SESSION:-main}"

if [ -n "${TMUX:-}" ] || [ -n "${DOTFILES_NO_TMUX:-}" ]; then
    exec "$SHELL_LAUNCHER"
fi

if [ ! -t 0 ] || [ ! -t 1 ]; then
    exec "$SHELL_LAUNCHER"
fi

if command -v tmux >/dev/null 2>&1; then
    exec tmux new-session -A -s "$TMUX_SESSION"
fi

exec "$SHELL_LAUNCHER"
