{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.applications.science;
in
{
  options.hatim.modules.applications.science = {
    enable = lib.mkEnableOption "scientific computing tools";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for scientific computing applications
    # Contents will be migrated from mod.apps.science.nix
  };
}
