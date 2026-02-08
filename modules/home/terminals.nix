{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hatim.modules.terminals;
in
{
  options.hatim.modules.terminals = {
    enable = lib.mkEnableOption "terminal emulator configurations";
    kitty.enable = lib.mkEnableOption "Kitty terminal" // {
      default = true;
    };
    foot.enable = lib.mkEnableOption "Foot terminal" // {
      default = true;
    };
    alacritty.enable = lib.mkEnableOption "Alacritty terminal" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      kitty = lib.mkIf cfg.kitty.enable {
        enable = true;
        shellIntegration.enableBashIntegration = true;
        shellIntegration.enableZshIntegration = true;
      };
      foot = lib.mkIf cfg.foot.enable { enable = true; };
      alacritty = lib.mkIf cfg.alacritty.enable { enable = true; };
    };

    home.packages = lib.optional cfg.foot.enable pkgs.st;
  };
}
