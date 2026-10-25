{ config, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.agent-instructions = {
    home-manager.users.${owner.username} =
      { lib, pkgs, ... }:
      let
        parts = [
          ./agent-instructions/core.md
          ./agent-instructions/codegraph.md
          ./agent-instructions/memory.md
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
