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
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/hatim/src/config.x/nx";
    };
    nix-index = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    nix-index-database.comma.enable = true;
  };

  home.packages = [
    # Cache
    pkgs.cachix
    pkgs.attic-client

    # Dev
    pkgs.nixd
    pkgs.nvd
    pkgs.manix

    pkgs.nix-output-monitor
    pkgs.nix-forecast
  ];
}
