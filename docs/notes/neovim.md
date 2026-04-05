# Neovim (nvf) Quick Reference

Config: `modules/editors.nix` | Leader: `Space` | Print generated config: `nvf-print-config | bat -l lua`

which-key uses the "helix" preset — press `Space` and wait to see all available bindings.

## Space Menu (Helix-style)

| Key | Action |
|-----|--------|
| `Space f` | Find files |
| `Space /` | Live grep |
| `Space b` | Switch buffer |
| `Space g` | Git changed files |
| `Space s` | Document symbols |
| `Space S` | Workspace symbols |
| `Space d` | Document diagnostics |
| `Space D` | Workspace diagnostics |
| `Space j` | Jumplist |
| `Space '` | Resume last picker |
| `Space ?` | Command palette |

## Core Navigation

| Key | Action |
|-----|--------|
| `C-h/j/k/l` | Navigate panes (vim-tmux-navigator, works across tmux) |
| `C-t` | Toggle terminal |
| `Space gg` | Open lazygit |

## Fuzzy Finder (fzf-lua) — Additional Commands

The space-menu bindings above cover the common pickers. These are available via command mode:

| Command | What it does |
|---------|-------------|
| `:FzfLua oldfiles` | Recent files |
| `:FzfLua git_commits` | Git log |
| `:FzfLua git_branches` | Git branches |
| `:FzfLua lsp_references` | LSP references |
| `:FzfLua lsp_definitions` | LSP definitions |
| `:FzfLua help_tags` | Search help |
| `:FzfLua keymaps` | Search keybindings |

Inside the picker: `C-j`/`C-k` to navigate, `Enter` to select, `Tab` for multi-select, `C-v` vertical split, `C-x` horizontal split.

## File Tree (neo-tree)

| Command | What it does |
|---------|-------------|
| `:Neotree toggle` | Toggle sidebar |
| `:Neotree reveal` | Open tree and focus current file |
| `:Neotree float` | Floating file browser |

Inside neo-tree: `Enter` open, `a` add file, `d` delete, `r` rename, `c` copy, `m` move, `q` close, `?` show help.

## LSP

Navigation pushes to the jumplist — use `C-o` to jump back, `C-i` to jump forward (like Emacs xref `M-,`/`M-.`).

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gy` | Go to type definition |
| `gi` | Go to implementation |
| `gr` | List references |
| `K` | Hover documentation |
| `Space a` | Code action |
| `Space r` | Rename symbol |
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |
| `Space lf` | Format buffer |
| `Space ltf` | Toggle format on save |
| `Space le` | Open diagnostic float |
| `Space ls` | Signature help |

## Trouble (Diagnostics Panel)

| Key | Action |
|-----|--------|
| `Space ld` | Document diagnostics |
| `Space lwd` | Workspace diagnostics |
| `Space lr` | LSP references |
| `Space xq` | Quickfix list |
| `Space xl` | Location list |
| `Space xs` | Symbols |

## Git (gitsigns)

| Key | Action |
|-----|--------|
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `Space hs` | Stage hunk |
| `Space hu` | Undo stage hunk |
| `Space hr` | Reset hunk |
| `Space hS` | Stage buffer |
| `Space hR` | Reset buffer |
| `Space hb` | Blame line |
| `Space tb` | Toggle inline blame |
| `Space hd` | Diff this |
| `Space hD` | Diff project |
| `Space td` | Toggle deleted lines |
| `Space hP` | Preview hunk inline |

## Completion (blink-cmp)

| Key | Action |
|-----|--------|
| `C-Space` | Trigger completion |
| `Tab` | Next item |
| `S-Tab` | Previous item |
| `Enter` | Confirm selection |
| `C-e` | Close menu |
| `C-d` | Scroll docs up |
| `C-f` | Scroll docs down |

## Comments

| Key | Action |
|-----|--------|
| `gcc` | Toggle line comment |
| `gbc` | Toggle block comment |
| `gc` + motion | Comment region (e.g., `gcap` = comment paragraph) |
| `gb` + motion | Block comment region |
| Visual `gc` | Comment selection |

## Surround

Default uses vendored keybindings (gz prefix). Standard ys/ds/cs available by setting `useVendoredKeybindings = false`.

| Key | Action | Example |
|-----|--------|---------|
| `gz` + motion + char | Add surround | `gziw"` = surround word with " |
| `gzz` + char | Surround line | `gzz)` = wrap line in () |
| `gzd` + char | Delete surround | `gzd"` = delete surrounding " |
| `gzr` + old + new | Change surround | `gzr"'` = change " to ' |
| Visual `gz` + char | Surround selection | |

## which-key

Press `Space` and wait — which-key shows available continuations. Useful for discovering bindings you've forgotten.

## Useful Vim Motions

| Key | Action |
|-----|--------|
| `ciw` | Change inner word |
| `ci"` | Change inside quotes |
| `di(` | Delete inside parens |
| `va{` | Select around braces |
| `gg` / `G` | Top / bottom of file |
| `*` / `#` | Search word under cursor forward / backward |
| `%` | Jump to matching bracket |
| `C-o` / `C-i` | Jump back / forward in jumplist |
| `zz` / `zt` / `zb` | Center / top / bottom cursor line |
| `.` | Repeat last change |
| `u` / `C-r` | Undo / redo |

## Configuration Notes

- **Theme**: tokyonight night (matches tmux theme)
- **Format on save**: enabled globally, toggle with `Space ltf`
- **Clipboard**: system clipboard via wl-copy (yank goes to system clipboard)
- **Inlay hints**: enabled (type hints in Rust/Go/TS)
- **Languages**: nix, lua, bash, python, go, rust, ts, html, css, svelte, tailwind, markdown, json, toml, yaml, sql, typst
- **Treesitter context**: sticky function/class headers at top of screen
- **Indent guides**: visible via indent-blankline
