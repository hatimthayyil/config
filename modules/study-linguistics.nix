{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.study-linguistics =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        home.packages = [
          pkgs.stable.praat
        ];
      };
    };
}
