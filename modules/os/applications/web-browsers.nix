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
    enable = lib.mkEnableOption "system web browser configuration";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for system web browser configuration
    # Contents will be migrated from hosts/mod.apps.web-browsers.nix
  };
}
