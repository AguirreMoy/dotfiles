if status is-interactive
    # Commands to run in interactive sessions can go here
    atuin init fish | source
end

function fish_greeting
    cat (random choice ~/.config/fish/greetings/*)
end

# TODO: path and aliases are kinda slow to source. optimize later. 
function ssource --description "source most of my dotfiles, useful if making changes and iterating"

    source ~/.config/fish/path.fish
    source ~/.config/fish/aliases.fish
    source ~/.config/fish/functions.fish
#    source ~/.config/fish/chromium.fish

    # pull in all shared `export …` aka `set -gx …`
#    source ~/.exports

    if test -e "$HOME/code/dotfiles/private/extras.fish";
        source $HOME/code/dotfiles/private/extras.fish
    end

    # for things not checked into git
    if test -e "$HOME/.extra.fish";
        source ~/.extra.fish
    end
end

ssource

#source ~/.cache/hellwal/variablesfish.fish
#fish ~/.cache/hellwal/terminal.sh

# Starship prompt
starship init fish | source

# Enable Transient Prompt
enable_transience

# zoxide setup
zoxide init --cmd cd fish | source

# atuin setup
atuin init fish | source

# Created by `pipx` on 2025-08-08 00:59:59
set PATH $PATH /Users/moy/Library/Python/3.13/bin
