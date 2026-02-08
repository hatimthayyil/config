{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.development;
in
{
  options.hatim.modules.development = {
    enable = lib.mkEnableOption "development environments and tools";
  };

  imports = [
    ./web.nix
    ./software.nix
    ./electronics.nix
    ./mechanical.nix
    ./version-control.nix
  ];

  config = lib.mkIf cfg.enable {
    # Development tools configured through submodules
  };
}
