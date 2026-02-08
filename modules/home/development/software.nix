{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.development.software;
in
{
  options.hatim.modules.development.software = {
    enable = lib.mkEnableOption "software development tools";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for software development
    # Contents will be migrated from mod.dsdv.software.nix
  };
}
