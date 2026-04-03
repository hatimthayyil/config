# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- `just build` - Build NixOS configuration (includes home-manager)
- `just switch` - Apply NixOS configuration
- `just clean` - Clean Nix store
- `nix fmt` - Format code with nixfmt-tree
- `nix build .#nixosConfigurations.eagle.config.system.build.toplevel` - Build without switching (safe verification)
- `nix eval .#nixosConfigurations.eagle.config.<path>` - Inspect a specific config value

## Architecture: Dendritic Pattern

This repo uses the **dendritic pattern** for NixOS configuration. Every `.nix` file under `modules/` is a flake-parts module auto-imported via `import-tree`.

### Key concepts
- **Named groups**: Each module contributes to `flake.modules.nixos.<group-name>`
- **Host selection**: `modules/hosts/eagle.nix` picks which groups to include
- **Cross-cutting**: A single file can set both NixOS and home-manager config
- **Auto-import**: `import-tree` discovers all `.nix` files under `modules/`; files prefixed with `_` are excluded

### Module anatomy

```nix
# modules/<feature>.nix — outer function is flake-parts, inner is deferred NixOS
{ config, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.<group-name> = { pkgs, ... }: {
    # NixOS config here
    home-manager.users.${owner.username} = {
      # Home-manager config here
    };
  };
}
```

### Directory structure
- `modules/infrastructure/` - Dendritic plumbing (flake-parts, configurations, home-manager wiring, meta)
- `modules/hosts/` - Per-host group selection
- `modules/hardware/` - Hardware-specific NixOS modules
- `modules/*.nix` - Feature modules (one per feature/topic)
- `modules/_*.nix` - HM module definitions excluded from auto-import

### Adding a new feature module
1. Create `modules/<feature>.nix` using the pattern above
2. Add the group name to `modules/hosts/eagle.nix` imports
3. `git add` the new file (flakes only see tracked files)
4. Verify with `nix build .#nixosConfigurations.eagle.config.system.build.toplevel`

## Code Style
- Use nixfmt-tree formatting standards
- Use nested attribute block style (not flat `programs.foo.bar = ...;`)
- Prefer declarative configurations over imperative changes
- Apply shellcheck conventions for any shell scripts

## Development Environment
- Uses direnv for environment management
- Git configured with difftastic for diffs
- Follows standard Nix flake conventions
