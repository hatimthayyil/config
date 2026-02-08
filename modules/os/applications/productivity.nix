{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.applications.productivity;
in
{
  options.hatim.modules.applications.productivity = {
    enable = lib.mkEnableOption "system productivity application configuration";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for system productivity applications
    # Contents will be migrated from hosts/mod.apps.productivity.nix
  };
}
