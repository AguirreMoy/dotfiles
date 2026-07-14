# Minimal zshrc

setopt AUTO_CD
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt INTERACTIVE_COMMENTS
setopt SHARE_HISTORY

autoload -Uz compinit
compinit -C

# Aliases
alias chmox='chmod +x'
alias cp='cp -v'
alias diskspace_report='df --si /'
alias dotfiles='subl ~/code/dotfiles'
alias grep='command grep --color=auto'
alias hosts='sudo ${EDITOR:-nvim} /etc/hosts'
if command -v lsd >/dev/null 2>&1; then
    alias la='lsd -F --group-directories-first -Al'
    alias ls='lsd -F --group-directories-first -A'
fi
alias push='git push'
alias resetmouse=$'printf "\\e[?1000l"'
alias rm='rm -v'
alias signaldone='printf "done\n" > /tmp/done_pipe'
alias sorteduniq='sort | uniq -c | sort --reverse --ignore-leading-blanks --numeric-sort'
alias sorteduniq-asc='sort | uniq -c | sort --ignore-leading-blanks --numeric-sort'
alias ungz='gunzip -k'
alias waitfordone='mkfifo /tmp/done_pipe 2>/dev/null || true; read -r _ < /tmp/done_pipe'
alias watchexec='command watchexec --project-origin . --ignore node_modules'
alias where='which'
alias wget='curl -L -O'
alias cleanup_dsstore='find . -name "*.DS_Store" -type f -ls -delete'

# dev-session standalone function
dev-session() {
    local SESSION_NAME=${1:-dev}
    local SESSION_DIR=${PWD}
    local SERVERS_WINDOW_NAME=${DOTFILES_DEV_SESSION_SERVERS_NAME:-servers}
    local MISC_WINDOW_NAME=${DOTFILES_DEV_SESSION_MISC_NAME:-misc}

    if ! command -v tmux >/dev/null 2>&1; then
        printf 'tmux is required for dev-session\n' >&2
        return 1
    fi

    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux new-session -d -s "$SESSION_NAME" -c "$SESSION_DIR"
        tmux new-window -d -t "$SESSION_NAME:2" -c "$SESSION_DIR"
        tmux new-window -d -t "$SESSION_NAME:3" -c "$SESSION_DIR"
        tmux new-window -d -t "$SESSION_NAME:4" -n "$SERVERS_WINDOW_NAME" -c "$SESSION_DIR"
        tmux new-window -d -t "$SESSION_NAME:5" -n "$MISC_WINDOW_NAME" -c "$SESSION_DIR"
        tmux select-window -t "$SESSION_NAME:1"
    fi

    if [ ! -t 0 ] || [ ! -t 1 ]; then
        return 0
    fi

    if [ -n "${TMUX:-}" ]; then
        tmux switch-client -t "$SESSION_NAME" 2>/dev/null && return 0
    fi

    exec tmux attach-session -t "$SESSION_NAME"
}

if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
    typeset -ga ZSH_AUTOSUGGEST_STRATEGY
    ZSH_AUTOSUGGEST_STRATEGY=(atuin history completion)
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
