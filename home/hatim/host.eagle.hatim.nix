{
  outputs,
  ...
}:

{
  imports = [
    # Home-manager modules
    ../../modules/home/enchant.nix
    # Configuration modules
    ./mod.nix.nix
    ./mod.package-management.nix
    ./mod.shells.nix
    ./mod.terminals.nix
    ./mod.editors.nix
    ./mod.version-control.nix
    ./mod.cli-utils.nix
    ./mod.desktop-wayland.nix
    ./mod.tools.backups.nix
    ./mod.tools.secrets.nix
    ./mod.apps.web-browsers.nix
    ./mod.apps.gui.nix
    ./mod.apps.science.nix
    ./mod.tools.research.nix
    ./mod.study.mathematics.nix
    ./mod.study.linguistics.nix
    ./mod.dsdv.software.nix
    ./mod.dsdv.web.nix
    ./mod.dsdv.electronics.nix
    ./mod.dsdv.mechanical.nix
    ./mod.language-machine.nix
    ./mod.networking.nix
    ./mod.containers.nix
    ./mod.multimedia.nix
    ./mod.fonts.nix
    ./mod.writing.nix
  ];

  home.username = "hatim";
  home.homeDirectory = "/home/hatim";

  # Check the Home Manager release notes before updating
  home.stateVersion = "24.11";

  # Environment variables
  home.sessionVariables = { };

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
