{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.tools;
in
{
  options.hatim.modules.tools = {
    enable = lib.mkEnableOption "utility tools";
  };

  imports = [
    ./backup.nix
    ./research.nix
    ./secrets.nix
  ];

  config = lib.mkIf cfg.enable {
    # Tools configured through submodules
  };
}
