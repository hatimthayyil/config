# Project Instructions

## Nix Sourcetrees

When adding or modifying home-manager or NixOS `programs.*` / `services.*` in this config:

- ALWAYS check the home-manager source tree at `/hatimthayyil/code/nix.home-manager/` to see what options are available.

  For example: `ls /hatimthayyil/code/nix.home-manager/modules/programs/<name>.nix` or using `grep`.

- ALWAYS check the Nixpkgs source tree at `/hatimthayyil/code/nixpkgs/` for package availability, module options, and program definitions.
