{ config, pkgs, inputs, ... }:

{
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

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  programs = {

    git = {
      enable = true;
      userEmail = "hatim@thayyil.net";
      userName = "Hatim Thayyil";
    };

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
    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
    alacritty.enable = true;
    kitty.enable = true;
    tmux.enable = true;

    # Utils
    yazi.enable = true;
    fd.enable = true;
    fzf.enable = true;
    bat.enable = true;
    zoxide.enable = true;
    fastfetch.enable = true;
    gpg.enable = true;

    # Editors
    neovim.enable = true;
    helix.enable = true;
    kakoune.enable = true;
    vscode.enable = true;

    # Dev
    direnv.enable = true;
    jq.enable = true; # JSON processor

    # Browsers
    firefox.enable = true;
    chromium.enable = true; # TODO make sure it uses ungoogled

    # Multimedia
    cmus.enable = true;
    mpv.enable = true;
    imv.enable = true;
    sioyek.enable = true;
  };

  # Home Packages
  home.packages = [
    # Terminals
    pkgs.st

    # Utils
    pkgs.tree # recursive listing of dirs
    pkgs.restic # backup
    pkgs.shellcheck
    pkgs.mr
    pkgs.btop

    # Dev
    pkgs.hyperfine # benchamarking tool
    pkgs.cloc # lines of code
    pkgs.gnumake
    pkgs.just
    pkgs.curl
    pkgs.curlie # frontend for curl
    pkgs.tig # TUI for git
    pkgs.mercurial
    pkgs.cvs

    # Editors
    pkgs.windsurf
    pkgs.code-cursor
    pkgs.vscodium-fhs

    # Messaging
    pkgs.telegram-desktop
    pkgs.signal-desktop
    pkgs.senpai # IRC

    # LSP
    pkgs.nixd

    # Tools
    pkgs.monolith # archive web-page
    pkgs.xdot # graph viewer
    pkgs.imagemagick
    pkgs.poppler
    pkgs.mediainfo

    # Browsers
    pkgs.librewolf
    pkgs.nyxt
    inputs.zen-browser.packages."x86_64-linux".default
    pkgs.tangram

    # GPU
    pkgs.glxinfo        # glxinfo, OpenGL (MESA)
    pkgs.vulkan-tools    # vulkaninfo : OpenGL alt (MESA)
    pkgs.libva-utils    # vainfo : Video Acceleration
    pkgs.clinfo         # clinfo : OpenCL (CUDA alt)
    pkgs.lact           # GPU config tool

    # ML
    pkgs.lmstudio
    pkgs.llama-cpp
    pkgs.jan

    # Astronomy
    pkgs.stellarium
    pkgs.celestia
    pkgs.gpredict
  ];
}
