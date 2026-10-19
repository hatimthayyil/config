{ config, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.agent-instructions = {
    home-manager.users.${owner.username} =
      { lib, ... }:
      let
        instructions =
          lib.concatMapStringsSep "\n" (part: builtins.readFile ./agent-instructions/${part}.md)
            [
              "core"
              "codegraph"
              "memory"
            ];
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
              text = instructions;
            });
      };
  };
}
