{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.terminals = {
    home-manager.users.${owner.username} =
      { pkgs, ... }:
      {
        programs = {
          kitty = {
            enable = true;
            shellIntegration.enableBashIntegration = true;
          };
          ghostty = {
            enable = true;
            enableBashIntegration = true;
            enableFishIntegration = true;
          };
        };

        gruvbox-kde.konsole.enable = true;

        xdg.configFile =
          let
            theme = name: "${pkgs.kitty-themes}/share/kitty-themes/themes/${name}.conf";
          in
          {
            "kitty/dark-theme.auto.conf".source = theme "gruvbox-dark-hard";
            "kitty/light-theme.auto.conf".source = theme "gruvbox-light-hard";
            "kitty/no-preference-theme.auto.conf".source = theme "gruvbox-light-hard";
          };

        home.packages = [
          # pkgs.unstable.warp-terminal
        ];
      };
  };
}
