{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
in
{
  #
  # ========== Option definitions for all NixOS modules
  #
  options.hatim.modules = {
    hardware = {
      enable = mkEnableOption "hardware configurations";
    };
    system = {
      enable = mkEnableOption "system-level configurations";
    };
    applications = {
      enable = mkEnableOption "system application configurations";
    };
  };

  #
  # ========== Import all submodules
  #
  imports = [
    ./hardware/default.nix
    ./system/default.nix
    ./applications/default.nix
  ];

  #
  # ========== Default enable/disable state for all modules
  #
  config = {
    hatim.modules = {
      hardware.enable = lib.mkDefault true;
      system.enable = lib.mkDefault true;
      applications.enable = lib.mkDefault true;
    };
  };
}
