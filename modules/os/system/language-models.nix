{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.system.languageModels;
in
{
  options.hatim.modules.system.languageModels = {
    enable = lib.mkEnableOption "language model service configuration";
  };

  config = lib.mkIf cfg.enable {
    # Placeholder for language models configuration
    # Contents will be migrated from hosts/mod.language-models.nix
  };
}
