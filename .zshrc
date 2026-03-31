# shellcheck shell=zsh

[[ -n ${DOTFILES_ZSHRC_LOADED:-} ]] && return
export DOTFILES_ZSHRC_LOADED=1

source "$HOME/.config/shell/common.sh"
dotfiles_load_shared_environment
dotfiles_prompt_my_env

setopt AUTO_CD
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt INTERACTIVE_COMMENTS
setopt SHARE_HISTORY

autoload -Uz compinit
compinit -C

export BAT_STYLE="changes,header-filename,header-filesize,snip,rule"
export ABBR_USER_ABBREVIATIONS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh-abbr/user-abbreviations"

source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/functions.zsh"

if command -v sheldon >/dev/null 2>&1; then
    eval "$(sheldon source)"
fi

if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
    typeset -ga ZSH_AUTOSUGGEST_STRATEGY
    ZSH_AUTOSUGGEST_STRATEGY=(atuin history completion)
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"
fi

if [[ -r "$HOME/code/dotfiles/private/extras.zsh" ]]; then
    source "$HOME/code/dotfiles/private/extras.zsh"
elif [[ -r "$HOME/code/dotfiles/private/extras.sh" ]]; then
    source "$HOME/code/dotfiles/private/extras.sh"
fi

if [[ -r "$HOME/.extra.zsh" ]]; then
    source "$HOME/.extra.zsh"
elif [[ -r "$HOME/.extra.sh" ]]; then
    source "$HOME/.extra.sh"
fi

dotfiles_show_greeting
dotfiles_apply_os_shell_setup

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if command -v zsh-patina >/dev/null 2>&1; then
    eval "$(zsh-patina activate)"
fi
