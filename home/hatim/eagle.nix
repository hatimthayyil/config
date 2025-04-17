{
  pkgs,
  ...
}:

{
  imports = [
    ./version-control.nix
    ./cli-utils.nix
    ./dekstop-wayland.nix
    ./gui-apps.nix
  ];

  home.username = "hatim";
  home.homeDirectory = "/home/hatim";

  # Check the Home Manager release notes before updating
  home.stateVersion = "24.11";

  # Dotfiles
  home.file = { };

  # Environment variables
  home.sessionVariables = { };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Manage nix binary
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  fonts.fontconfig.enable = true;

  programs = {

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/hatim/src/config.x/nx";
    };

    # Shell
    bash.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      history.size = 10000;
    };
    nushell.enable = true;
    oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      useTheme = "star";
    };
    alacritty.enable = true;
    kitty.enable = true;

    # Utils
    gpg.enable = true;

    # Dev
    direnv.enable = true;
    jq.enable = true; # JSON processor
  };

  # Home Packages
  home.packages = [
    # Terminals
    pkgs.st
    pkgs.wl-clipboard

    # Utils
    pkgs.tree # recursive listing of dirs
    pkgs.restic # backup
    pkgs.shellcheck

    # Dev
    pkgs.gnumake
    pkgs.just
    pkgs.curl
    pkgs.curlie # frontend for curl

    # LSP
    pkgs.nixd

    # Tools
    pkgs.monolith # archive web-page
    pkgs.xdot # graph viewer
    pkgs.imagemagick
    pkgs.poppler
    pkgs.mediainfo

    # GPU
    pkgs.glxinfo # glxinfo, OpenGL (MESA)
    pkgs.vulkan-tools # vulkaninfo : OpenGL alt (MESA)
    pkgs.libva-utils # vainfo : Video Acceleration
    pkgs.clinfo # clinfo : OpenCL (CUDA alt)
    pkgs.lact # GPU config tool

    # ML
    pkgs.lmstudio
    pkgs.llama-cpp
    pkgs.jan

    # Astronomy
    pkgs.stellarium
    pkgs.celestia
    pkgs.gpredict

    # Secret
    pkgs.pass
  ];
}
