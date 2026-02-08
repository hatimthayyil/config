{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.hardware;
in
{
  options.hatim.modules.hardware = {
    enable = lib.mkEnableOption "hardware configurations";
  };

  imports = [
    ./laptop.nix
    ./lenovo-thinkpad-p52.nix
  ];

  config = lib.mkIf cfg.enable {
    # Hardware configuration through submodules
  };
}
