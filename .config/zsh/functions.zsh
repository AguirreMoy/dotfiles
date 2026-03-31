..() { cd ..; }
...() { cd ../..; }
....() { cd ../../..; }
.....() { cd ../../../..; }

ag() {
    command ag -W "$(( COLUMNS - 14 ))" "$@"
}

all_binaries_in_path() {
    local finder
    finder=$(command -v gfind 2>/dev/null || command -v find)
    "$finder" -L ${(s/:/)PATH} -maxdepth 1 -executable -type f 2>/dev/null
}

all_binaries_in_path_grep() {
    all_binaries_in_path | grep "$@"
}

beep() {
    printf '\a'
    sleep 0.1
    printf '\a'
}

clone() {
    git clone --depth=1 "$1" || return
    cd "${${1:t}%.git}" || return
    yarn install
}

conda() {
    unfunction conda 2>/dev/null || true
    eval "$(command conda shell.zsh hook)"
    conda "$@"
}

cargo() {
    unfunction cargo 2>/dev/null || true
    [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
    command cargo "$@"
}

delbranch() {
    git branch -D "$1" && git push paul ":$1"
}

dotfiles_show_greeting() {
    [[ -n ${DOTFILES_GREETING_SHOWN:-} ]] && return 0
    local greetings
    greetings=("$HOME"/.config/fish/greetings/*(N))
    (( ${#greetings} )) || return 0
    export DOTFILES_GREETING_SHOWN=1
    cat -- "${greetings[RANDOM % ${#greetings} + 1]}"
}

dotfiles_apply_os_shell_setup() {
    case "$(uname)" in
        Darwin)
            if [[ ${MY_ENV:-} == personal ]]; then
                ssh-add --apple-load-keychain >/dev/null 2>&1 || true
            fi
            ;;
    esac
}

dotfiles_terminal_title_context() {
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null) || git_root=
    if [[ -n "$git_root" ]]; then
        basename "$git_root"
    elif [[ $PWD == "$HOME" ]]; then
        printf '~\n'
    else
        basename "$PWD"
    fi
}

dotfiles_set_terminal_title() {
    printf '\033]0;%s\007' "$1"
}

dotfiles_update_terminal_title_precmd() {
    dotfiles_set_terminal_title "$(dotfiles_terminal_title_context)"
}

dotfiles_update_terminal_title_preexec() {
    local command_title=${1%%$'\n'*}
    dotfiles_set_terminal_title "${command_title:-$(dotfiles_terminal_title_context)}"
}

fns() {
    local config_dir="$HOME/.config/zsh"
    rg '^[[:space:]]*[[:alnum:]_]+\(\)[[:space:]]*\{' "$config_dir" -n --color always | \
        fzf --ansi --layout reverse --border rounded --preview 'bat --color=always --style=plain --line-range :500 {1}'
}

gemi() {
    if [[ -z ${1:-} ]]; then
        llm chat -m gemini-2.5-flash
    else
        llm prompt -m gemini-2.5-flash "$*" && echo "Rendered output:" && llm logs -r | glow
    fi
}

gitmainormaster() {
    local branch
    branch=$(git branch --format '%(refname:short)' --sort=-committerdate --list master main | head -n 1)
    printf '%s\n' "${branch:-main}"
}

gz() {
    local file=$1
    local orig_size wid method compressed_size bar_width

    orig_size=$(wc -c < "$file")
    printf "%-20s %12s\n" "compression method" "bytes"

    for method in "original" "gzip (-5)"; do
        case "$method" in
            "original") compressed_size=$(wc -c < "$file") ;;
            "gzip (-5)") compressed_size=$(gzip -5 -c < "$file" | wc -c) ;;
        esac

        wid=$(( COLUMNS > 40 ? COLUMNS - 40 : 20 ))
        bar_width=$(( compressed_size * wid / orig_size ))
        printf "%-20s %12s   %s%s\n" \
            "$method" \
            "$compressed_size" \
            "$(printf '%*s' "$bar_width" '' | tr ' ' '#')" \
            "$(printf '%*s' "$(( wid - bar_width ))" '' | tr ' ' '.')"
    done
}

killport() {
    local selection pid
    selection=$(
        lsof -iTCP -sTCP:LISTEN -P 2>/dev/null | awk 'NR>1 {print $2, $9}' | uniq | while read -r pid port; do
            local command_display
            command_display=$(ps -p "$pid" -o command=)
            printf '%-6s %-24s %s\n' "$pid" "${port/localhost/}" "$command_display"
        done | \
            fzf --exact --tac --preview 'pstree -p $(echo {} | awk "{print \$1}")' --preview-window=down,30% --header "Select a process to kill (PID Port Command):"
    )

    pid=$(printf '%s\n' "$selection" | awk '{print $1}')
    [[ -n "$pid" ]] && kill -9 "$pid"
}

killprocess() {
    local pid
    pid=$(ps aux | fzf -m --header-lines=1 | awk '{print $2}')
    [[ -n "$pid" ]] && kill -9 $pid
}

list_path() {
    print -l ${(s/:/)PATH}
}

main() {
    git checkout "$(gitmainormaster)"
}

master() {
    main
}

maxcpu100() {
    local cores
    echo "To stop the pain run:"
    echo "killall yes"
    cores=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
    for _ in $(seq "$cores"); do
        yes >/dev/null &
    done
}

md() {
    command mkdir -p "$@" || return
    case "${@: -1}" in
        -*) ;;
        *) cd "${@: -1}" || return ;;
    esac
}

notif() {
    local last_command
    last_command=$(fc -ln -1)
    osascript \
        -e 'on run argv' \
        -e 'return display notification item 1 of argv with title "command done" sound name "Submarine"' \
        -e 'end' \
        -- "$last_command"
}

openai() {
    if [[ -z ${1:-} ]]; then
        llm chat -m gpt-4o
    else
        llm prompt -m gpt-4o "$*" && echo "Rendered output:" && llm logs -r | glow
    fi
}

renameurldecode() {
    local original decoded
    for original in *; do
        decoded=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote_plus(sys.argv[1]))' "$original")
        [[ "$original" == "$decoded" ]] || mv "$original" "$decoded"
    done
}

server() {
    if [[ -n ${1:-} ]]; then
        if [[ $1 == <-> ]]; then
            statikk --open --port "$@"
        else
            statikk --open "$@"
        fi
    else
        statikk --open
    fi
}

shellswitch() {
    local target shell_path
    target=${1:?usage: shellswitch [bash|zsh|fish]}
    shell_path=$(command -v "$target" 2>/dev/null) || return 1
    mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/shell"
    printf '%s\n' "$target" > "${XDG_CONFIG_HOME:-$HOME/.config}/shell/active-shell"
    exec "$shell_path" -l
}

ssource() {
    source "$HOME/.config/shell/common.sh"
    dotfiles_load_shared_environment
    source "$HOME/.config/zsh/aliases.zsh"
    source "$HOME/.config/zsh/functions.zsh"
}

stab() {
    local vid=$1
    ffmpeg -i "$vid" -vf "vidstabdetect=stepsize=32:result=${vid}.trf" -f null - &&
        ffmpeg -i "$vid" -b:v 5700K -vf "vidstabtransform=interpol=bicubic:input=${vid}.trf" "${vid}.mkv" &&
        ffmpeg -i "$vid" -i "${vid}.mkv" -b:v 3000K -filter_complex hstack "${vid}.stack.mkv" &&
        command rm "${vid}.trf"
}

subl() {
    if [[ -d "/Applications/Sublime Text.app" ]]; then
        "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "$@"
    elif [[ -d "/Applications/Sublime Text 2.app" ]]; then
        "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" "$@"
    elif [[ -x "/opt/sublime_text/sublime_text" ]]; then
        "/opt/sublime_text/sublime_text" "$@"
    elif [[ -x "/opt/sublime_text_3/sublime_text" ]]; then
        "/opt/sublime_text_3/sublime_text" "$@"
    else
        echo "No Sublime Text installation found"
        return 1
    fi
}
