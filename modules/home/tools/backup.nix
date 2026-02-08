{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.tools.backup;
in
{
  options.hatim.modules.tools.backup = {
    enable = lib.mkEnableOption "backup tools";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for backup tools
    # Contents will be migrated from mod.tools.backups.nix
  };
}
