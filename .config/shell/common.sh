# shellcheck shell=sh

[ -n "${DOTFILES_SHELL_COMMON_LOADED:-}" ] && return 0
DOTFILES_SHELL_COMMON_LOADED=1

dotfiles_trim_line() {
    printf '%s' "$1" | sed 's|#.*$||' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

dotfiles_expand_home() {
    value=$1
    case "$value" in
        "~") value=$HOME ;;
        "~"/*) value=$HOME/${value#"~/"} ;;
    esac

    printf '%s' "$value" | sed "s|\$HOME|$HOME|g"
}

dotfiles_load_env_file() {
    env_file=$1
    [ -f "$env_file" ] || return 0

    while IFS= read -r raw_line || [ -n "$raw_line" ]; do
        line=$(dotfiles_trim_line "$raw_line")
        [ -n "$line" ] || continue

        case "$line" in
            *=*)
                key=$(printf '%s' "${line%%=*}" | sed 's/[[:space:]]*$//')
                value=$(printf '%s' "${line#*=}" | sed 's/^[[:space:]]*//')
                value=$(dotfiles_expand_home "$value")
                export "$key=$value"
                ;;
        esac
    done < "$env_file"
}

dotfiles_prepend_path() {
    path_entry=$1
    [ -d "$path_entry" ] || [ -L "$path_entry" ] || return 0

    case ":${PATH:-}:" in
        *:"$path_entry":*) ;;
        *)
            if [ -n "${PATH:-}" ]; then
                PATH=$path_entry:$PATH
            else
                PATH=$path_entry
            fi
            export PATH
            ;;
    esac
}

dotfiles_load_path_file() {
    path_file=$1
    [ -f "$path_file" ] || return 0

    while IFS= read -r raw_line || [ -n "$raw_line" ]; do
        line=$(dotfiles_trim_line "$raw_line")
        [ -n "$line" ] || continue
        dotfiles_prepend_path "$(dotfiles_expand_home "$line")"
    done < "$path_file"
}

dotfiles_source_if_exists() {
    file_to_source=$1
    [ -f "$file_to_source" ] || return 0
    # shellcheck disable=SC1090
    . "$file_to_source"
}

dotfiles_load_shared_environment() {
    [ -n "${DOTFILES_SHARED_ENV_LOADED:-}" ] && return 0
    DOTFILES_SHARED_ENV_LOADED=1

    dotfiles_load_env_file "$HOME/.envs"
    dotfiles_load_env_file "$HOME/.envs.environment"
    dotfiles_load_path_file "$HOME/.paths"
    dotfiles_load_path_file "$HOME/.paths.environment"

    dotfiles_source_if_exists "$HOME/.local/bin/env"
    dotfiles_source_if_exists "$HOME/.atuin/bin/env"
}

dotfiles_detect_my_env() {
    [ -n "${MY_ENV:-}" ] && return 0

    for candidate in "$HOME/.envs.environment" "$HOME/.gitconfig.environment"; do
        [ -L "$candidate" ] || continue
        target=$(readlink "$candidate" 2>/dev/null || true)
        case "$target" in
            *personal*)
                MY_ENV=personal
                export MY_ENV
                return 0
                ;;
            *work*)
                MY_ENV=work
                export MY_ENV
                return 0
                ;;
        esac
    done

    return 1
}

dotfiles_prompt_my_env() {
    [ -n "${MY_ENV:-}" ] || dotfiles_detect_my_env || true
    [ -n "${MY_ENV:-}" ] && return 0

    case $- in
        *i*) ;;
        *) return 0 ;;
    esac

    while :; do
        printf 'MY_ENV not set. Please choose your environment:\n'
        printf '1) Personal\n'
        printf '2) Work\n'
        printf 'Selection: '
        read -r choice

        case "$choice" in
            1)
                MY_ENV=personal
                export MY_ENV
                break
                ;;
            2)
                MY_ENV=work
                export MY_ENV
                break
                ;;
            *)
                printf 'Invalid selection. Please try again.\n'
                ;;
        esac
    done

    printf "MY_ENV set to '%s'.\n" "$MY_ENV"
}
