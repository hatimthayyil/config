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
  # ========== Option definitions for all home-manager modules
  #
  options.hatim.modules = {
    shells = {
      enable = mkEnableOption "shell configurations";
    };
    editors = {
      enable = mkEnableOption "editor configurations";
    };
    terminals = {
      enable = mkEnableOption "terminal emulator configuration";
    };
    applications = {
      enable = mkEnableOption "application configurations";
    };
    development = {
      enable = mkEnableOption "development tools and environments";
    };
    system = {
      enable = mkEnableOption "system-level configuration";
    };
    tools = {
      enable = mkEnableOption "utility tools";
    };
    study = {
      enable = mkEnableOption "educational tools";
    };
    writing = {
      enable = mkEnableOption "writing and documentation tools";
    };
    languageMachine = {
      enable = mkEnableOption "language model and AI tools";
    };
    nix = {
      enable = mkEnableOption "Nix-specific tools and configuration";
    };
  };

  #
  # ========== Import all submodules
  #
  imports = [
    ./shells/default.nix
    ./editors/default.nix
    ./terminals.nix
    ./applications/default.nix
    ./development/default.nix
    ./system/default.nix
    ./tools/default.nix
    ./study/default.nix
    ./writing.nix
    ./language-machine.nix
    ./nix.nix
    ./enchant.nix
  ];

  #
  # ========== Default enable/disable state for all modules
  #
  # Set defaults to true so everything is enabled by default
  # Users can override specific modules in their host config
  #
  config = {
    hatim.modules = {
      shells.enable = lib.mkDefault true;
      editors.enable = lib.mkDefault true;
      terminals.enable = lib.mkDefault true;
      applications.enable = lib.mkDefault true;
      development.enable = lib.mkDefault true;
      system.enable = lib.mkDefault true;
      tools.enable = lib.mkDefault true;
      study.enable = lib.mkDefault true;
      writing.enable = lib.mkDefault true;
      languageMachine.enable = lib.mkDefault true;
      nix.enable = lib.mkDefault true;
    };
  };
}
