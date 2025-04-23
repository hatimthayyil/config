{
  pkgs,
  ...
}: {
  # Manage nix binary
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    settings.substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

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
    pkgs.nix-direnv
    pkgs.nvd
    pkgs.manix

    pkgs.nix-output-monitor
    pkgs.nix-forecast
  ];
}
