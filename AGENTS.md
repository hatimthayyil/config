# Project Instructions

Provide your task to subagents. Spawn multiple agents when needed. Tasks that have serial dependance can be handed out to multiple agents one after the other. It is preferred to give one logical task to one agent.

## Nix Sourcetrees

When adding or modifying home-manager or NixOS `programs.*` / `services.*` in this config:

- ALWAYS check the home-manager source tree at `/hatimthayyil/code/nix.home-manager/` to see what options are available.

  For example: `ls /hatimthayyil/code/nix.home-manager/modules/programs/<name>.nix` or using `grep`.

- ALWAYS check the Nixpkgs source tree at `/hatimthayyil/code/nixpkgs/` for package availability, module options, and program definitions.
