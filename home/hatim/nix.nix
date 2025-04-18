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
  };

  programs = {
    home-manager.enable = true;
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/hatim/src/config.x/nx";
    };
  };

  home.packages = [
    # LSP
    pkgs.nixd
  ];
}
