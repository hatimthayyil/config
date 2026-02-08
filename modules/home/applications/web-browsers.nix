{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.applications.webBrowsers;
in
{
  options.hatim.modules.applications.webBrowsers = {
    enable = lib.mkEnableOption "web browser configurations";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for web browsers
    # Contents will be migrated from mod.apps.web-browsers.nix
  };
}
