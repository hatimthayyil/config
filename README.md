# NixOS Configuration

Dendritic NixOS configuration using flake-parts and import-tree.

## Quick Reference

```bash
just build      # Build without applying
just switch     # Apply configuration
just update     # Update flake inputs
just upgrade    # Update + build + switch
just clean      # Garbage collect nix store
just forecast   # Preview what would be rebuilt
```

## Rollback

If something breaks after switching:

```bash
just rollback       # Switch to previous generation
just rollback 42    # Switch to a specific generation
just generations    # List all available generations
```

If the system won't boot, select a previous generation from the
**systemd-boot menu** at startup.

## Adding a Feature Module

Create `modules/<feature>.nix`:

```nix
{ config, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.<feature> = { pkgs, ... }: {
    # NixOS config here
    home-manager.users.${owner.username} = {
      # Home-manager config here
    };
  };
}
```

Then add the group to `modules/hosts/eagle.nix` and run `just switch`.
