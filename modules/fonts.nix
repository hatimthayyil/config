{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        fonts.fontconfig.enable = true;

        home.packages = with pkgs; [
          nerd-fonts.symbols-only
        ];
      };
    };
}
