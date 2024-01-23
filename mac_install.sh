brew install font-victor-mono-nerd-font
brew install nvim:q

brew install starship
echo "starship init fish | source"" >> ~/.config/fish/config.fish
starship preset pastel-powerline -o ~/.config/starship.toml
