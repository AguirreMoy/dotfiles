#!/bin/sh

set -eu

command_name=${1:-}
pane_path=${2:-}

basename_safe() {
    path=$1
    if [ -z "$path" ] || [ "$path" = "/" ]; then
        printf '/'
        return
    fi
    basename "$path"
}

context=$(basename_safe "$pane_path")

case "$command_name" in
    nvim|vim|vi)
        printf ' %s' "$context"
        ;;
    ssh)
        printf '󰣀 ssh'
        ;;
    lazygit|git)
        printf '󰊢 %s' "$context"
        ;;
    node|bun|deno|pnpm|npm|yarn)
        printf ' %s' "$context"
        ;;
    python|python3|ipython)
        printf ' %s' "$context"
        ;;
    docker|lazydocker)
        printf ' %s' "$context"
        ;;
    zsh|bash|fish)
        printf ' %s' "$context"
        ;;
    *)
        if [ -n "$command_name" ] && [ "$command_name" != "$SHELL" ]; then
            printf '%s' "$command_name"
        else
            printf '%s' "$context"
        fi
        ;;
esac
