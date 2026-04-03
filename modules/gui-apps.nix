{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.gui-apps =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        programs = {
          cmus.enable = true;
          mpv.enable = true;
          imv.enable = true;
          zathura.enable = true;
          sioyek.enable = true;
          onlyoffice.enable = true;

          thunderbird = {
            enable = true;
            profiles."default".isDefault = true;
          };
        };

        home.packages = [
          pkgs.qdirstat
          pkgs.mailspring
          pkgs.telegram-desktop
          pkgs.signal-desktop
          pkgs.senpai
          pkgs.discord
          pkgs.element-desktop
          pkgs.zoom-us
          pkgs.drawio
          pkgs.blender
          pkgs.filezilla
        ];
      };
    };
}
