{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.applications.gui;
in
{
  options.hatim.modules.applications.gui = {
    enable = lib.mkEnableOption "GUI applications";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for GUI applications
    # Contents will be migrated from mod.apps.gui.nix
  };
}
