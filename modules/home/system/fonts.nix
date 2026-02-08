{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.system.fonts;
in
{
  options.hatim.modules.system.fonts = {
    enable = lib.mkEnableOption "font configuration";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for fonts configuration
    # Contents will be migrated from mod.fonts.nix
  };
}
