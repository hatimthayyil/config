{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.system;
in
{
  options.hatim.modules.system = {
    enable = lib.mkEnableOption "system-level configurations";
  };

  imports = [
    ./networking.nix
    ./package-management.nix
    ./containers.nix
    ./input-devices.nix
    ./guest-systems.nix
    ./language-models.nix
  ];

  config = lib.mkIf cfg.enable {
    # System configuration through submodules
  };
}
