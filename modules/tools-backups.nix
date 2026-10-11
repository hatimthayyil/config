{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.tools-backups =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        services = {
          syncthing.enable = true;
          nextcloud-client.enable = true;
        };

        home.packages = [
          pkgs.filen-desktop
          pkgs.filen-cli
        ];
      };
    };
}
