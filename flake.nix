{
  description = "Nix configuration flake";

  inputs = {
    #
    # ========== Primary NixOS pkgs
    #
    #nixpkgs.url = "github:nixos/nixpkgs/master";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    #
    # ========== Pinned versions available as pkgs.stable etc
    #
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    #
    # ========== Home manager
    #
    home-manager = {
      url = "github:nix-community/home-manager/master";
      #url = "github:nix-community/home-manager/release-24.11";

      # To be kept up to date with nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #
    # ========== Utilities
    #
    # Flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Hardware
    hardware.url = "github:nixos/nixos-hardware/master";
    # Declarative partitioning and formatting
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Impermanance
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    # Secrets management.
    sops-nix = {
      url = "github:mic92/sops-nix";
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
    # Nixpak - sandbox any app
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #
    # ========== Applications
    #
    # Nix User Repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      #url = "github:nix-community/nixvim";
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Zed Editor (upstream broken)
    zed-editor = {
      url = "github:HPsaucii/zed-editor-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Zen browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so
      # ensure to have it up to date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # MacOS Ventura, and other Guest OSes
    nixtheplanet.url = "github:matthewcroughan/nixtheplanet";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem =
        { system, pkgs, ... }:
        {
          # Nix formatter available through 'nix fmt'
          formatter = pkgs.nixfmt-tree;

          # VM application
          apps.vm = {
            type = "app";
            program = "${inputs.self.nixosConfigurations.owl.config.system.build.vm}/bin/run-nixos-vm";
          };
        };

      imports = [
        ./overlays
      ];

      flake = {
        #
        # ========== Host configurations
        #
        nixosConfigurations = {
          eagle = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              inputs.hardware.nixosModules.lenovo-thinkpad-p52
              inputs.nix-flatpak.nixosModules.nix-flatpak
              ./hosts/eagle
              inputs.nixtheplanet.nixosModules.macos-ventura
            ];
            specialArgs = {
              inherit inputs;
              outputs = inputs.self;
            };
          };
        };

        #
        # ========== User home configuration
        #
        homeConfigurations = {
          "hatim@eagle" = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
              overlays = [ inputs.self.overlays.default ];
            };

            modules = [
              ./home/hatim/host.eagle.hatim.nix
              inputs.nix-index-database.hmModules.nix-index
              inputs.emx.homeManagerModules.default
              inputs.nvf.homeManagerModules.default
            ];

            # Pass through arguments to home.nix
            extraSpecialArgs = {
              inherit inputs;
              outputs = inputs.self;
            };
          };
        };
      };
    };
}
