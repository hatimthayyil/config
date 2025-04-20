{
  description = "Nix configuration flake";

  inputs = {
    #
    # ========== Official NixOS
    #
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Pinned versions for critical applications
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      #url = "github:nix-community/home-manager/release-24.11";

      # To be kept up to date with nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware
    hardware.url = "github:nixos/nixos-hardware/master";
    # Nix User Repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #
    # ========== Utilities
    #
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
    # Nix based neovim
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      #url = "github:nix-community/nixvim";
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Pre-commit
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Emacs
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Local modules
    emx-local.url = "path:///home/hatim/src/emx";
    # Zen browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so
      # ensure to have it up to date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nur,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      #
      # ========== Architectures
      #
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        #"aarch64-darwin"
      ];
    in
    {

      #
      # ========== Overlays
      #
      overlays = import ./overlays { inherit inputs; };

      #
      # ========== Formatting
      #
      # Nix formatter available through 'nix fmt' https://github.com/NixOS/nixfmt
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      #
      # ========== Host configurations
      #
      nixosConfigurations.eagle = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/eagle
        ];
        specialArgs = { inherit inputs outputs; };
      };

      #
      # ========== User home configuration
      #
      homeConfigurations = {
        "hatim@eagle" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = [ outputs.overlays.default ];
          };

          modules = [
            ./home/hatim/eagle.nix
            inputs.emx-local.homeManagerModules.default
          ];

          # Pass through arguments to home.nix
          extraSpecialArgs = { inherit inputs outputs; };
        };
      };

      apps."x86_64-linux".vm = {
        type = "app";
        program = "${self.nixosConfigurations.owl.config.system.build.vm}/bin/run-nixos-vm";
      };
    };
}
