{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.dev-electronics = _: {
    # TODO Wine-compatible Microcap is provided by
    # https://github.com/emmanuelrosa/erosanix
    home-manager.users.${owner.username} = {
      home.packages = [
        # pkgs.stable.kicad-small # unstable is broken, manage imperatively
      ];
    };
  };
}
