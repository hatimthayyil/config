{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.study-math =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        home.packages = [
          pkgs.maxima
          pkgs.octave
          pkgs.coq
          pkgs.lean4
          pkgs.stable.sage
        ];
      };
    };
}
