if status is-interactive
    if not set -q MY_ENV
        while true
            echo "MY_ENV not set. Please choose your environment:"
            echo "1) Personal"
            echo "2) Work"
            read -P "Selection: " choice
            switch $choice
                case 1
                    set -Ux MY_ENV personal
                    break
                case 2
                    set -Ux MY_ENV work
                    break
                case '*'
                    echo "Invalid selection. Please try again."
            end
        end
        echo "MY_ENV set to '$MY_ENV'."
    end

    # Commands to run in interactive sessions can go here
    atuin init fish | source
end

function fish_greeting
    cat (random choice ~/.config/fish/greetings/*)
end

# TODO: path and aliases are kinda slow to source. optimize later. 
function ssource --description "source most of my dotfiles, useful if making changes and iterating"

    source ~/.config/fish/path.fish
    source ~/.config/fish/env.fish
    source ~/.config/fish/aliases.fish
    source ~/.config/fish/functions.fish
    #    source ~/.config/fish/chromium.fish

    # pull in all shared `export …` aka `set -gx …`
    #    source ~/.exports

    if test -e "$HOME/code/dotfiles/private/extras.fish"

        source $HOME/code/dotfiles/private/extras.fish
    end

    # for things not checked into git
    if test -e "$HOME/.extra.fish"

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

# OS-specific settings
set -l USER (whoami)
switch (uname)
    case Darwin
        # do things for macOS
        if test "$MY_ENV" = personal
            # Start the agent in the background if it's not already running
            # Check if the socket is actually responding
            if not ssh-add -l >/dev/null 2>&1
                # If we are here, the socket is either missing OR stale (Connection refused)
                # We remove the stale file just in case pass-cli doesn't handle it well
                rm -f $SSH_AUTH_SOCK
                # Start it up
                pass-cli ssh-agent start >/dev/null 2>&1 &
            end
        end
    case Linux
        # do things for Linux
    case '*'
        # do things for other OSs
end

# Created by `pipx` on 2025-08-08 00:59:59
set PATH $PATH /Users/moy/Library/Python/3.13/bin
