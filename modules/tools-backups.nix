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
      systemd.tmpfiles.rules = [ "d /hatimthayyil/filen 0750 ${owner.username} users - -" ];

      home-manager.users.${owner.username} =
        { config, ... }:
        {
          services = {
            syncthing.enable = true;
            nextcloud-client.enable = true;
          };

          home = {
            packages = [
              pkgs.filen-desktop
              pkgs.filen-cli
            ];
            file."filen".source = config.lib.file.mkOutOfStoreSymlink "/hatimthayyil/filen";
          };
        };
    };
}
