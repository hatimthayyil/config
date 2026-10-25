{ config, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.agent-instructions = {
    home-manager.users.${owner.username} =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        gitbutler = config.programs.gitbutler;
        # gitbutler.md is copied from this version's wizard text (policy.rs).
        gitbutlerPoliciesVersion = "0.22.3";
        parts = [
          ./agent-instructions/core.md
          ./agent-instructions/codegraph.md
          ./agent-instructions/memory.md
        ]
        ++ lib.optionals gitbutler.enable [
          gitbutler.agentPolicy
          ./agent-instructions/gitbutler.md
        ];
        instructions = pkgs.runCommand "agent-instructions.md" { } ''
          sep=
          for part in ${lib.escapeShellArgs (map (part: "${part}") parts)}; do
            printf '%s' "$sep" >> $out
            cat "$part" >> $out
            sep=$'\n'
          done
        '';
      in
      {
        warnings =
          lib.optional (gitbutler.enable && gitbutler.package.version != gitbutlerPoliciesVersion)
            "agent-instructions/gitbutler.md is copied from but ${gitbutlerPoliciesVersion}; re-copy the policies from but ${gitbutler.package.version}'s policy.rs.";
        xdg.configFile =
          lib.genAttrs
            [
              "agents/AGENTS.md"
              "agents/claude.md"
              "agents/codex.md"
              "agents/pi.md"
            ]
            (_: {
              source = instructions;
            });
      };
  };
}
