{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.hardware.laptop;
in
{
  options.hatim.modules.hardware.laptop = {
    enable = lib.mkEnableOption "laptop hardware configuration";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for laptop hardware configuration
    # Contents will be migrated from hosts/mod.hw.laptop.nix
  };
}
