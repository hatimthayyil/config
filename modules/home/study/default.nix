{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.study;
in
{
  options.hatim.modules.study = {
    enable = lib.mkEnableOption "educational tools";
  };

  imports = [
    ./mathematics.nix
    ./linguistics.nix
  ];

  config = lib.mkIf cfg.enable {
    # Study tools configured through submodules
  };
}
