if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_greeting
    cat (random choice ~/.config/fish/greetings/*)
end

starship init fish | source
