#!/bin/sh

SHELL_LAUNCHER="${XDG_CONFIG_HOME:-$HOME/.config}/shell/launch-shell.sh"
TMUX_SESSION="${DOTFILES_TMUX_SESSION:-main}"

if [ -n "${TMUX:-}" ] || [ -n "${DOTFILES_NO_TMUX:-}" ]; then
    exec "$SHELL_LAUNCHER"
fi

for path_entry in /opt/homebrew/bin /usr/local/bin "$HOME/.local/bin"; do
    case ":${PATH:-}:" in
        *:"$path_entry":*) ;;
        *) PATH="$path_entry${PATH:+:$PATH}" ;;
    esac
done
export PATH

if command -v tmux >/dev/null 2>&1; then
    exec tmux new-session -A -s "$TMUX_SESSION"
fi

exec "$SHELL_LAUNCHER"
