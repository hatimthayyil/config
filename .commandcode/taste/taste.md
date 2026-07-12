# Taste (Continuously Learned by [CommandCode][cmd])

[cmd]: https://commandcode.ai/

# Encryption
- Prefer age over GPG for encryption and identity management. Confidence: 0.85

# git
- Commit changes in logical discrete units, never combining unrelated changes. Confidence: 0.75
- Use brief, neutral commit messages without vendor hardware names. Confidence: 0.75

# nix
- Always consult the home-manager or nixpkgs source tree before adding or modifying program configurations, to understand existing options, integrations, and defaults. Confidence: 0.85
- Keep NixOS-level nix settings (e.g., distributedBuilds, buildMachines) in modules/base.nix, not in modules/nix.nix which is for home-manager configurations only. Confidence: 0.70
- Use the nested attribute form when writing Nix options (e.g., `programs.ssh.extraConfig` and `programs.ssh.knownHosts` rather than flattening), unless existing code already uses a different pattern. Confidence: 0.80

