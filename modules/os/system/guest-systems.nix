{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.system.guestSystems;
in
{
  options.hatim.modules.system.guestSystems = {
    enable = lib.mkEnableOption "guest system support";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for guest systems configuration
    # Contents will be migrated from hosts/mod.guest-systems.nix
  };
}
