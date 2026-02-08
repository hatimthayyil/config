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
    ./desktop.nix
    ./networking.nix
    ./multimedia.nix
    ./fonts.nix
    ./containers.nix
  ];

  config = lib.mkIf cfg.enable {
    # System configuration through submodules
  };
}
