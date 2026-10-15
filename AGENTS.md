# AGENTS.md

NixOS and home-manager configuration for host `eagle`.

## Commands
- `just build`: build the NixOS configuration, including home-manager.
- `just switch`: apply it.
- `just clean`: clean the Nix store.
- `nix fmt`: format with nixfmt-tree.
- `nix build .#nixosConfigurations.eagle.config.system.build.toplevel`: build without switching.
- `nix eval .#nixosConfigurations.eagle.config.<path>`: inspect a config value.

## Architecture: dendritic pattern
Every `.nix` file under `modules/` is a flake-parts module, auto-imported by `import-tree`; files prefixed `_` are excluded. Each module contributes to `flake.modules.nixos.<group>`, and `modules/hosts/eagle.nix` selects the groups. One file may set both NixOS and home-manager config.

```nix
{ config, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.<group> = { pkgs, ... }: {
    home-manager.users.${owner.username} = {
    };
  };
}
```

- `modules/infrastructure/`: flake-parts, configurations, home-manager wiring, meta.
- `modules/hosts/`: per-host group selection.
- `modules/hardware/`: hardware modules.
- `modules/*.nix`: one feature per file.
- `home/hatim/`: mutable agent and app directories, linked out of store.

To add a feature: create `modules/<feature>.nix`, add its group to `modules/hosts/eagle.nix`, `git add` it (flakes see only tracked files), then build.

Global agent instructions are composed from `modules/agent-instructions/*.md` into `~/.config/agents/`; the agent directories link there.

## Option sources
Before adding or changing `programs.*` or `services.*`, check the options in the local source trees:
- home-manager: `/hatimthayyil/code/nix.home-manager/`
- Nixpkgs: `/hatimthayyil/code/nixpkgs/`

## Style
- nixfmt-tree formatting.
- Nested attribute blocks, not flat `programs.foo.bar = ...;`.
- Declarative over imperative.
- Shell scripts follow shellcheck.
