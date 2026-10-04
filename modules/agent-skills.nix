{ config, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.agent-skills = {
    home-manager.users.${owner.username} =
      { config, ... }:
      {
        home.file.".agents".source =
          config.lib.file.mkOutOfStoreSymlink "/home/hatim/code/config/home/hatim/agents";
      };
  };
}
