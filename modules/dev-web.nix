{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.dev-web =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        home.packages = [
          pkgs.httpie
          pkgs.httplab
        ];
      };
    };
}
