# Home-Manager Modules

This directory contains all home-manager module configurations organized by category.

## Module Organization

- **shells/**: Shell configurations (bash, zsh, fish, nushell)
- **editors/**: Text editors (emacs, neovim, vscode)
- **applications/**: End-user applications (GUI apps, CLI tools)
- **development/**: Development environments (web, software, electronics, mechanical)
- **system/**: System-level configuration (desktop, networking, multimedia, etc.)
- **tools/**: Utility tools (backup, research, secrets management)
- **study/**: Educational tools (mathematics, linguistics)
- **terminals.nix**: Terminal emulator configuration
- **writing.nix**: Writing and documentation tools
- **language-machine.nix**: LLM/AI tools
- **nix.nix**: Nix-specific tools and configuration

## How to Use

Each module can be independently enabled/disabled through the home configuration options.
See `default.nix` for the entry point and which modules are currently active.

## Adding a New Module

1. Create a new `.nix` file in the appropriate category directory
2. Follow the standard enable/disable pattern (see examples below)
3. Add the module import to the appropriate `default.nix`
4. Configure the enable/disable option in your home configuration

## Standard Module Pattern

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.hatim.modules.category;
in
{
  options.hatim.modules.category = {
    enable = lib.mkEnableOption "description of category";
    # ... additional options
  };

  config = lib.mkIf cfg.enable {
    # Configuration here
  };
}
```
