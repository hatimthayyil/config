{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.dev-mechanical =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        home.packages = [
          pkgs.freecad
        ];
      };
    };
}
