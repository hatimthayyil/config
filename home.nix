{ config, pkgs, ... }:

{
  home.username = "hatim";
  home.homeDirectory = "/home/hatim";

  # Check the Home Manager release notes before updating
  home.stateVersion = "24.11";

  # Dotfiles
  home.file = {};

  # Environment variables
  home.sessionVariables = {};

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Manage nix binary
  nix = {
          package = pkgs.nix;
          settings.experimental-features = [ "nix-command" "flakes" ];
  };

  #fonts.fontconfig.enable = true;

  targets.genericLinux.enable = true;

  # TODO Enable after switching to NixOS
  #programs.bash.enable = true;

  programs.zsh = {
          enable = true;
          enableCompletion = true;
          syntaxHighlighting.enable = true;

          shellAliases = {
                  ll = "ls -l";
          };
          history.size = 10000;
          oh-my-zsh = {
                  enable = true;
                  plugins = [ "git" ];
                  theme = "robbyrussell";
          };
  };

  programs.starship = {
          enable = true;
          settings = {
                  add_newline = true;
                  character = {
                          success_symbol = "[➜](bold green)";
                          error_symbol = "[➜](bold red)";
                  };
          };
  };

  programs.nh = {
          enable = true;
          clean.enable = true;
          clean.extraArgs = "--keep-since 4d --keep 3";
          flake = "/home/hatim/src/config.x/nx";
  };

  programs.git = {
          enable = true;
          userEmail = "hatim@thayyil.net";
          userName = "Hatim Thayyil";
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
  };

  programs = {
          # Shell
          nushell.enable = true;
          tmux.enable = true;
          alacritty.enable = true;

          # Shell Utils
          kitty.enable = true;
          yazi.enable = true;
          fd.enable = true;
          fzf.enable = true;
          bat.enable = true;
          zoxide.enable = true;
          fastfetch.enable = true;

          # Editors
          neovim.enable = true;
          helix.enable = true;
          kakoune.enable = true;
          vscode.enable = true;

          # Dev
          mr.enable = true;
          direnv.enable = true;
          jq.enable = true;     # JSON processor

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
  home.packages = with pkgs; [
          # Terminals
          st

          # Utils
          tree                  # recursive listing of dirs
          restic                # backup
          shellcheck

          # Dev
          hyperfine             # benchamarking tool
          cloc                  # lines of code
          gnumake
          curl
          curlie              # frontend for curl
          tig                 # TUI for git
          mercurial
          cvs

          # Editors
          windsurf
          code-cursor
          vscodium-fhs

          # Messaging
          telegram-desktop
          signal-desktop
          senpai              # IRC

          # LSP
          nixd

          # Tools
          monolith              # archive web-page
          xdot                  # graph viewer
          imagemagick
          poppler
          mediainfo

          # Browsers
          librewolf
          nyxt
  ];

}
