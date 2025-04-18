{
  pkgs,
  ...
}:

{
  imports = [
    ./nix.nix
    ./shells.nix
    ./terminals.nix
    ./secrets.nix
    ./software-development.nix
    ./version-control.nix
    ./cli-utils.nix
    ./dekstop-wayland.nix
    ./gui-apps.nix
    ./machine-imprinting.nix
    ./science.nix
    ./multimedia.nix
    ./research-tools.nix
    ./backups.nix
  ];

  home.username = "hatim";
  home.homeDirectory = "/home/hatim";

  # Check the Home Manager release notes before updating
  home.stateVersion = "24.11";

  # Dotfiles
  home.file = { };

  # Environment variables
  home.sessionVariables = { };

  fonts.fontconfig.enable = true;
}
