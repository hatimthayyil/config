{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.science =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        home.packages = [
          pkgs.stellarium
          pkgs.stable.celestia
          pkgs.gpredict
        ];
      };
    };
}
