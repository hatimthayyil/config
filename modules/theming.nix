{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.theming =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        polarity = "light";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-light-hard.yaml";
        # default true clobbers pre-existing configs of apps never asked for here
        autoEnable = false;
      };

      home-manager.users.${owner.username}.stylix.targets = {
        tmux.enable = true;
        bat.enable = true;
        fzf.enable = true;
        vivid.enable = true; # generates LS_COLORS for eza, see modules/cli-utils.nix
      };
    };
}
