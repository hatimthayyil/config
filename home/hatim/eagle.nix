{
  outputs,
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
    ./editors.nix
    ./version-control.nix
    ./cli-utils.nix
    ./dekstop-wayland.nix
    ./gui-apps.nix
    ./language-machine.nix
    ./science.nix
    ./multimedia.nix
    ./research-tools.nix
    ./backups.nix
    ./design-electronics.nix
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

  #
  # ========== Nixpkgs with overlays
  #
  nixpkgs = {
    overlays = [
      outputs.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };
}
