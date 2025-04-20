# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- `just build` - Build OS and home configurations
- `just switch` - Apply OS and home configurations
- `just clean` - Clean Nix store
- `just os` - Update OS configuration
- `just home` - Update home configuration
- `nix fmt` - Format code with nixfmt-tree

## Code Style
- Use nixfmt-tree formatting standards
- Follow existing file structure and naming patterns
- Preserve existing module import ordering
- Prefer declarative configurations over imperative changes
- Use clear, descriptive attribute names
- Keep configurations organized by functional domain
- Apply shellcheck conventions for any shell scripts

## Development Environment
- Uses direnv for environment management
- Git configured with difftastic for diffs
- Follows standard Nix flake conventions
- Respects NixOS module system patterns