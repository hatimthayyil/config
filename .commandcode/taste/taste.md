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
- Use the nested attribute form when writing Nix options (e.g., `sops = { age = ...; secrets = ...; }` rather than `sops.age = ...; sops.secrets = ...;`), unless existing code already uses a different pattern. Confidence: 0.85

# workflow
- State intent before making major tool calls — say what you're about to do and why, before invoking the tool, not just a post-hoc summary. Confidence: 0.90
- Ground diagnosis in verified facts from authoritative sources (docs, source code, man pages) rather than speculation or assumptions; the user explicitly rejects unverified claims. Confidence: 0.80
- Investigate root cause first, then act — don't jump to solutions or propose changes before understanding what the actual issue is. Confidence: 0.75

