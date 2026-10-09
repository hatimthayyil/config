{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.terminals = {
    home-manager.users.${owner.username} = {
      programs = {
        ghostty = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
        };
      };

      gruvbox-kde.konsole.enable = true;

      home.packages = [
        # pkgs.unstable.warp-terminal
      ];
    };
  };
}
