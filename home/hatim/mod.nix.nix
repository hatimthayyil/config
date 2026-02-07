{
  pkgs,
  ...
}:
{
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
      frequency = "3:15"; #The format is described in {manpage}systemd.time(7).
      useFlake = true;
    };
  };

  home.packages = [
    # Cache
    pkgs.cachix
    pkgs.attic-client

    # Dev
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
    pkgs.nvd
    pkgs.nixfmt

    pkgs.lorri

    pkgs.nix-output-monitor
    pkgs.nix-forecast
  ];
}
