{
  outputs,
  ...
}:

{
  imports = [
    ./nix.nix
    ./shells.nix
    ./terminals.nix
    ./mod.editors.nix
    ./mod.version-control.nix
    ./cli-utils.nix
    ./dekstop-wayland.nix
    ./language-machine.nix
    ./multimedia.nix
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
    ./mod.networking.nix
    ./mod.containers.nix
  ];

  home.username = "hatim";
  home.homeDirectory = "/home/hatim";

  # Check the Home Manager release notes before updating
  home.stateVersion = "24.11";

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
