{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.study.linguistics;
in
{
  options.hatim.modules.study.linguistics = {
    enable = lib.mkEnableOption "linguistics tools";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for linguistics tools
    # Contents will be migrated from mod.study.linguistics.nix
  };
}
