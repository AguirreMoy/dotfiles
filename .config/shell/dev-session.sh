#!/bin/sh

set -eu

SESSION_NAME=${1:-dev}
SESSION_DIR=${PWD}
SERVERS_WINDOW_NAME=${DOTFILES_DEV_SESSION_SERVERS_NAME:-servers}
MISC_WINDOW_NAME=${DOTFILES_DEV_SESSION_MISC_NAME:-misc}

if ! command -v tmux >/dev/null 2>&1; then
    printf 'tmux is required for dev-session\n' >&2
    exit 1
fi

create_session() {
    tmux new-session -d -s "$SESSION_NAME" -c "$SESSION_DIR"
    tmux new-window -d -t "$SESSION_NAME:2" -c "$SESSION_DIR"
    tmux new-window -d -t "$SESSION_NAME:3" -c "$SESSION_DIR"
    tmux new-window -d -t "$SESSION_NAME:4" -n "$SERVERS_WINDOW_NAME" -c "$SESSION_DIR"
    tmux new-window -d -t "$SESSION_NAME:5" -n "$MISC_WINDOW_NAME" -c "$SESSION_DIR"
    tmux select-window -t "$SESSION_NAME:1"
}

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    create_session
fi

if [ ! -t 0 ] || [ ! -t 1 ]; then
    exit 0
fi

if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "$SESSION_NAME" 2>/dev/null && exit 0
fi

exec tmux attach-session -t "$SESSION_NAME"
