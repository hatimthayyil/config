{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.applications;
in
{
  options.hatim.modules.applications = {
    enable = lib.mkEnableOption "application configurations";
  };

  imports = [
    ./gui/default.nix
    ./cli/default.nix
    ./web-browsers.nix
    ./science.nix
  ];

  config = lib.mkIf cfg.enable {
    # Applications are configured through submodules
  };
}
