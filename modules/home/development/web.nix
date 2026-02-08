{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.development.web;
in
{
  options.hatim.modules.development.web = {
    enable = lib.mkEnableOption "web development tools";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for web development
    # Contents will be migrated from mod.dsdv.web.nix
  };
}
