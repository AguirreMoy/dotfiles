# dotfiles

My personal shell/editor/terminal setup with **Ghostty + zsh + tmux + Neovim** as the main path, while still keeping **fish** and **Kitty** working.

## Quick start

Run:

```sh
bash sync.sh
```

`sync.sh`:

- detects Linux vs macOS
- prompts for `MY_ENV` (`personal` or `work`) if needed
- prompts for the active shell (`zsh` or `fish`) if needed
- installs packages through `linux/install.sh` or `mac/install.sh`
- symlinks the tracked configs into `$HOME`

Useful overrides:

```sh
MY_ENV=personal DOTFILES_SHELL=zsh bash sync.sh
MY_ENV=work DOTFILES_SHELL=fish bash sync.sh
```

## Layout

| Path | Purpose |
| --- | --- |
| `.config/ghostty/config` | Primary terminal config |
| `.config/kitty/kitty.conf` | Secondary terminal config |
| `.config/tmux/tmux.conf` | tmux config |
| `.zshrc`, `.zprofile`, `.config/zsh/` | zsh setup |
| `.config/fish/` | fish setup |
| `.config/shell/common.sh` | shared env/path loading |
| `.config/shell/launch-shell.sh` | terminal-driven shell launcher |
| `.config/nvim/` | Neovim / LazyVim config |
| `.config/hellwal/` | color generation templates |
| `.cache/hellwal/` | generated terminal color files |

## Shell setup

### zsh (primary)

zsh is the main interactive shell now. It uses:

- **Sheldon** for plugin loading
- **Atuin** for history and autosuggestion strategy
- **zoxide** for `cd`
- **Starship** prompt
- **zsh-patina** when installed
- shared env/path loading from `.envs`, `.paths`, and their environment overlays
- Ghostty title hooks so tabs show the repo/directory while idle and the current command while running

### fish (still supported)

fish is preserved and kept usable. It has matching greeting/title behavior plus the older alias/function set and Fisher-based plugin setup.

### Shared shell behavior

`~/.config/shell/launch-shell.sh` decides which shell to launch based on:

1. `DOTFILES_SHELL`
2. `~/.config/shell/active-shell`
3. fallback shell state

That means the terminal chooses the shell. The account login shell is not changed by this repo.

## Terminal setup

### Ghostty (primary)

Ghostty is the default terminal path I am optimizing for.

Highlights:

- Victor Mono Nerd Font
- `Medium` normal weight and `Bold` bold weight
- hellwal-generated colors via `~/.cache/hellwal/ghostty-colors.conf`
- 90% background opacity
- macOS glass blur (`macos-glass-regular`)
- shell launched through `~/.config/shell/launch-shell.sh`
- Ghostty title handling disabled so shell hooks control titles cleanly

### Kitty (secondary)

Kitty stays configured and usable, including:

- hellwal colors
- Victor Mono Nerd Font setup
- powerline tab styling
- cursor trail effects
- shell launched through the same shell wrapper

## tmux setup

tmux is configured in `.config/tmux/tmux.conf` with a minimal, no-plugin setup.

Defaults:

- `tmux-256color` + truecolor overrides for Ghostty/Kitty
- mouse support enabled
- vi-style copy mode
- clipboard integration enabled
- large history
- window/pane numbering starts at `1`
- new panes/windows inherit the current path
- new shells start through `~/.config/shell/launch-shell.sh`

Useful tmux shortcuts:

| Shortcut | Action |
| --- | --- |
| `Ctrl-b |` | split horizontally |
| `Ctrl-b -` | split vertically |
| `Ctrl-b c` | new window in current path |
| `Ctrl-b e` | open a new window running `nvim` |
| `Ctrl-b h/j/k/l` | move between panes |
| `Ctrl-b H/J/K/L` | resize panes |
| `Ctrl-b Ctrl-h` / `Ctrl-b Ctrl-l` | previous/next window |
| `Ctrl-b Tab` | jump to the last window |
| `Ctrl-b r` | reload tmux config |
| copy mode `v` / `y` | begin selection / copy |

## Neovim setup

Neovim lives under `.config/nvim/` and is based on **LazyVim**.

The bundled `.config/nvim/README.md` is still the stock LazyVim starter note; the real setup is in the Lua files here:

- `init.lua`
- `lua/config/options.lua`
- `lua/config/keymaps.lua`
- `lua/plugins/*.lua`

### Neovim choices and creature comforts

- leader is **Space**
- local leader is `\`
- autoformat is enabled
- root detection prefers LSP, then `.git`/`lua`, then cwd
- clipboard uses `unnamedplus`
- mouse is enabled
- line numbers are on
- relative numbers are off
- 2-space indentation
- wrap is off
- smooth scroll enabled on Neovim 0.10+
- folding is effectively open by default (`foldlevel = 99`)

### LSP and diagnostics

Custom LSP/diagnostic mappings from `init.lua`:

| Key | Action |
| --- | --- |
| `<space>e` | open diagnostic float |
| `[d` / `]d` | previous / next diagnostic |
| `<space>q` | diagnostics to location list |
| `gD` | declaration |
| `gd` | definition |
| `K` | hover |
| `gi` | implementation |
| `<C-k>` | signature help |
| `<space>wa` / `<space>wr` / `<space>wl` | workspace folder actions |
| `<space>D` | type definition |
| `<space>rn` | rename |
| `<space>ca` | code action |
| `gr` | references |
| `<space>f` | format buffer |

### Plugin/tooling customizations

Current custom plugin files show these explicit choices:

- **Catppuccin** as the chosen colorscheme
- **Treesitter** plus textobjects
- **Conform** using `black` and `isort` for Python
- **nvim-lint** configured for fish and Ruff-based linting workflow
- **Mason** ensuring `black`, `isort`, `ruff`, `stylua`, `shellcheck`, `shfmt`, and `flake8`
- **emoji completion** through `cmp-emoji`

LazyVim also brings in the rest of the editor baseline (completion UI, file navigation, git signs, diagnostics UI, etc.).

## Shell aliases, shortcuts, and creature comforts

### Shared/important aliases

These are present in zsh and largely mirrored in fish:

| Name | Meaning |
| --- | --- |
| `ls`, `la` | `lsd` with directory-first output |
| `cp`, `rm` | verbose copy/remove |
| `where` | `which` |
| `grep` | colorized grep |
| `wget` | `curl -L -O` |
| `dig` | short DNS answer view |
| `hosts` | edit `/etc/hosts` in `$EDITOR` |
| `push` | `git push` |
| `dotfiles` | open the dotfiles repo in Sublime Text |
| `cleanup_dsstore` | remove `.DS_Store` files recursively |
| `diskspace_report` | `df --si /` |
| `ungz` | `gunzip -k` |
| `sorteduniq`, `sorteduniq-asc` | count/sort repeated lines |
| `resetmouse` | disable mouse reporting escape mode |
| `signaldone`, `waitfordone` | simple cross-shell done/wait pipe |
| `li`, `lperf` | Lighthouse helpers |
| `comp`, `reportunit`, `reportwatch` | project-specific report helpers |
| `xpraclient` | attach to a preset xpra target |

### zsh functions

Custom zsh functions include:

- `..`, `...`, `....`, `.....`
- `ag`
- `all_binaries_in_path`, `all_binaries_in_path_grep`
- `beep`
- `clone`
- `conda`
- `cargo`
- `delbranch`
- `dotfiles_show_greeting`
- `dotfiles_apply_os_shell_setup`
- `dotfiles_terminal_title_context`
- `dotfiles_set_terminal_title`
- `dotfiles_update_terminal_title_precmd`
- `dotfiles_update_terminal_title_preexec`
- `fns`
- `gemi`
- `gitmainormaster`
- `gz`
- `killport`
- `killprocess`
- `list_path`
- `main`, `master`
- `maxcpu100`
- `md`
- `notif`
- `openai`
- `renameurldecode`
- `server`
- `shellswitch`
- `ssource`
- `stab`
- `subl`

### fish-specific extras

fish keeps parity on most aliases/functions and also has extra abbreviations such as:

- `g`, `gi`, `gti` -> git
- `yearn` -> yarn
- `v` -> vim
- `bwre`, `brwe` -> brew
- `cat` -> `bat -P`
- `mtr` -> `sudo mtr`

## AI helpers

Two shell helpers wrap Simon Willison's `llm` CLI:

| Command | Purpose |
| --- | --- |
| `gemi` | Gemini chat/prompt helper |
| `openai` | OpenAI chat/prompt helper |

With no args they open chat; with args they run a prompt and then render the latest output with `glow`.

## Environment switching

The setup supports `personal` and `work` overlays through `MY_ENV`.

Shared logic in `.config/shell/common.sh`:

- loads `.envs` + `.envs.environment`
- loads `.paths` + `.paths.environment`
- sources optional env helpers from `~/.local/bin/env` and `~/.atuin/bin/env`
- tries to infer `MY_ENV` from symlink targets
- prompts interactively if the environment is still unknown

## Notes

- Ghostty/zsh is the primary path.
- Kitty/fish are still preserved.
- tmux is intentionally plugin-free right now.
- The repo may contain local machine-specific fish state that is not meant to be committed; the tracked shell setup lives in the stable config files above.
