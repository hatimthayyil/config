{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.system.packageManagement;
in
{
  options.hatim.modules.system.packageManagement = {
    enable = lib.mkEnableOption "system package management configuration";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for package management
    # Contents will be migrated from hosts/mod.package-management.nix
  };
}
