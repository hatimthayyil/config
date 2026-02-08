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
    enable = lib.mkEnableOption "system application configurations";
  };

  imports = [
    ./web-browsers.nix
    ./productivity.nix
  ];

  config = lib.mkIf cfg.enable {
    # Applications configured through submodules
  };
}
