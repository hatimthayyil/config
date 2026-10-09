{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.terminals = {
    home-manager.users.${owner.username} =
      { pkgs, lib, ... }:
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
          konsole = {
            enable = true;
            defaultProfile = "Gruvbox Light";
            profiles =
              lib.mapAttrs
                (_: colorScheme: {
                  inherit colorScheme;
                  font.name = "Hack";
                })
                {
                  "Gruvbox Light" = "GruvboxLightHard";
                  "Gruvbox Dark" = "GruvboxDarkHard";
                };
            extraConfig.LightDarkTheme = {
              SyncProfileWithSystemTheme = true;
              LightThemeProfile = "Gruvbox Light";
              DarkThemeProfile = "Gruvbox Dark";
            };
          };
        };

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
          inputs.gruvbox-kde.packages.${pkgs.stdenv.hostPlatform.system}.konsole
          # pkgs.unstable.warp-terminal
        ];
      };
  };
}
