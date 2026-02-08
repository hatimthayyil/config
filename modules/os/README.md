# NixOS Modules

This directory contains all NixOS system-level module configurations organized by category.

## Module Organization

- **hardware/**: Hardware-specific configurations (laptop, specific hardware profiles)
- **system/**: System services and utilities (networking, package management, containers, etc.)
- **applications/**: System-wide application configurations (web browsers, productivity tools)

## How to Use

Each module can be independently enabled/disabled through NixOS options.
See `default.nix` for the entry point and which modules are currently active.

## Standard Module Pattern

```nix
{ config, lib, ... }:
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
