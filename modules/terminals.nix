{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.terminals =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        programs = {
          kitty = {
            enable = true;
            shellIntegration.enableBashIntegration = true;
            shellIntegration.enableZshIntegration = true;
          };
          ghostty = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
          };
        };

        home.packages = [
          pkgs.unstable.warp-terminal
        ];
      };
    };
}
