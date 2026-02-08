{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.applications.cli;
in
{
  options.hatim.modules.applications.cli = {
    enable = lib.mkEnableOption "CLI applications";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for CLI applications
    # Contents will be migrated from mod.cli-utils.nix
  };
}
