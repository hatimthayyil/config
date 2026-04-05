# Tmux Keybindings

Prefix: `Ctrl+Space`

## Sessions

| Key | Description |
|-----|-------------|
| `prefix + s` | Session picker (sesh + fzf) |
| `prefix + Ctrl-s` | Save session (resurrect) |
| `prefix + Ctrl-r` | Restore session (resurrect) |

Sessions auto-save every 1 minute and auto-restore on tmux start via continuum.

## Windows

| Key | Description |
|-----|-------------|
| `Alt+1..9` | Switch to window 1-9 (no prefix) |
| `prefix + c` | New window (keeps current path) |
| `prefix + Space` | Toggle last window |
| `prefix + <` | Swap window left |
| `prefix + >` | Swap window right |
| `prefix + &` | Kill window (no confirmation) |

## Panes

### Navigation (no prefix, seamless with neovim via vim-tmux-navigator)

| Key | Description |
|-----|-------------|
| `Alt+h` | Navigate left (neovim-aware) |
| `Alt+j` | Navigate down (neovim-aware) |
| `Alt+k` | Navigate up (neovim-aware) |
| `Alt+l` | Navigate right (neovim-aware) |
| `Alt+Left/Down/Up/Right` | Select pane (tmux-only, not neovim-aware) |

### Splitting

| Key | Description |
|-----|-------------|
| `prefix + v` | Split horizontal (keeps current path) |
| `prefix + h` | Split vertical (keeps current path) |

### Resizing (no prefix)

| Key | Description |
|-----|-------------|
| `Alt+Shift+Left` | Resize left |
| `Alt+Shift+Down` | Resize down |
| `Alt+Shift+Up` | Resize up |
| `Alt+Shift+Right` | Resize right |

### Other

| Key | Description |
|-----|-------------|
| `Alt+z` | Zoom/unzoom pane (no prefix) |
| `prefix + S` | Synchronize panes (type in all panes) |
| `prefix + x` | Kill pane (no confirmation) |

## Copy Mode (vi)

| Key | Description |
|-----|-------------|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Yank selection (yank plugin) |
| `o` | Open file in `$EDITOR` / URL in browser (open plugin) |
| `Ctrl+o` | Open with `$EDITOR` (open plugin) |

## Plugins

| Key | Description |
|-----|-------------|
| `prefix + Space` | tmux-thumbs: hint-copy visible text (URLs, paths, hashes) |
| `prefix + u` | fzf-tmux-url: pick and open/copy visible URLs |
| `prefix + tab` | extrakto: fuzzy search all visible text |
| `prefix + p` | tmux-floax: toggle floating scratch pane |

## General

| Key | Description |
|-----|-------------|
| `prefix + r` | Reload config |
