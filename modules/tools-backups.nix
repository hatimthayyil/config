{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.tools-backups = _: {
    home-manager.users.${owner.username} = {
      services.syncthing.enable = true;
      services.nextcloud-client.enable = true;
    };
  };
}
