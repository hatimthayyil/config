{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.dev-mechanical =
    _: {
      home-manager.users.${owner.username} = {
        home.packages = [
          # pkgs.freecad
        ];
      };
    };
}
