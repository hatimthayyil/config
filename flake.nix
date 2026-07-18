{
  description = "Nix configuration flake";

  inputs = {
    #
    # ========== Primary NixOS pkgs
    #
    # Avoid master (rolling, unfiltered).
    # nixpkgs.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    #
    # ========== Pinned versions available as pkgs.stable etc
    #
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    #
    # ========== Home manager
    #
    # The nixpkgs version here is just for the Homemanager flake,
    # and does not affect the pkgs instance used in the config.
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-25.11";

      # To be kept up to date with nixpkgs
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    #
    # ========== Utilities
    #
    # Flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Auto-import modules
    import-tree.url = "github:vic/import-tree";
    # Hardware
    hardware.url = "github:nixos/nixos-hardware/master";
    # Declarative partitioning and formatting
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Impermanance
    # impermanence = {
    #   url = "github:nix-community/impermanence";
    # };
    # Secrets management.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Niks3 CLI, tracking upstream main
    niks3 = {
      url = "github:Mic92/niks3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix-index
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Flake based configuration of Treefmt
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Pre-commit
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Parallel evaluation and builds
    nix-fast-build = {
      url = "github:Mic92/nix-fast-build";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Nixpak - sandbox any app
    # nixpak = {
    #   url = "github:nixpak/nixpak";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    #
    # ========== Applications
    #
    # Nix User Repository
    # nur = {
    #   url = "github:nix-community/NUR";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # Flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # Emacs
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # EmX Emacs distribution
    emx = {
      url = "github:hatimthayyil/emx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix based Neovim
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix based neovim
    # nixvim = {
    #   url = "github:nix-community/nixvim/nixos-24.11";
    #   inputs.nixpkgs.follows = "nixpkgs-stable";
    #   #url = "github:nix-community/nixvim";
    #   #inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Claude Desktop (Linux port with FHS variant for MCP server support)
    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Zen browser
    # zen-browser = {
    #   url = "github:0xc000022070/zen-browser-flake";
    #   # IMPORTANT: we're using "libgbm" and is only available in unstable so
    #   # ensure to have it up to date or simply don't specify the nixpkgs input
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    # Firefox Add-ons
    nix-firefox-addons = {
      url = "github:osipog/nix-firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    betterfox = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Firefox CSS hacks (non-flake)
    firefox-csshacks = {
      url = "github:MrOtherGuy/firefox-csshacks";
      flake = false;
    };
    # Modus theme for tmux (local until pushed to GitHub)
    tmux-modus = {
      url = "git+file:///hatimthayyil/code/tmux-modus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Modus themes for Claude Code (local until pushed to GitHub)
    claude-code-modus = {
      url = "git+file:///hatimthayyil/code/claude-code-modus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # MacOS Ventura, and other Guest OSes
    # nixtheplanet.url = "github:matthewcroughan/nixtheplanet";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { config, lib, ... }:
      {
        imports = [ (inputs.import-tree ./modules) ];

        perSystem =
          { system, ... }:
          let
            nixosConfigs = config.flake.nixosConfigurations or { };
            checksForThisSystem = lib.filterAttrs (
              _name: nixosConfig: nixosConfig.pkgs.system == system
            ) nixosConfigs;
          in
          {
            packages.nix-fast-build = inputs.nix-fast-build.packages.${system}.default;

            checks = lib.mapAttrs' (
              name: nixosConfig: lib.nameValuePair "nixos-${name}" nixosConfig.config.system.build.toplevel
            ) checksForThisSystem;
          };

        flake.templates = import ./templates;
      }
    );
}
