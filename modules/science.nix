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
          pkgs.stable.stellarium
          pkgs.stable.celestia
          pkgs.stable.gpredict
        ];
      };
    };
}
