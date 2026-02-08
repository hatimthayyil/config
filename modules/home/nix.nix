{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hatim.modules.nix;
in
{
  options.hatim.modules.nix = {
    enable = lib.mkEnableOption "Nix-specific tools and configuration";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      home-manager.enable = true;
      nh = {
        enable = true;
        clean.enable = true;
        flake = "/home/hatim/code/config";
      };
      nix-index = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
      nix-index-database.comma.enable = true;
    };

    services.home-manager = {
      autoUpgrade = {
        flakeDir = "/home/hatim/code/config";
        frequency = "3:15";
        useFlake = true;
      };
    };

    home.packages = [
      pkgs.cachix
      pkgs.attic-client
      pkgs.nixd
      pkgs.nil
      pkgs.nvd
      pkgs.manix
      pkgs.nix-health
      pkgs.deadnix
      pkgs.statix
      pkgs.nix-update
      pkgs.nix-diff
      pkgs.nix-du
      pkgs.nix-init
      pkgs.nix-melt
      pkgs.nix-tree
      pkgs.lorri
      pkgs.nix-output-monitor
      pkgs.nix-forecast
      pkgs.nixfmt
    ];
  };
}
