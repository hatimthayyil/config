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
      inputs.nixpkgs.follows = "nixpkgs";
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
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    emacs-overlay,
    ...
  }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
          "windsurf"
          "cursor"
          "vscode"
        ];
      };
    in {

      nixosConfigurations.eagle = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };

      homeConfigurations."hatim" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };

      apps."x86_64-linux".vm = {
        type = "app";
        program = "${self.nixosConfigurations.owl.config.system.build.vm}/bin/run-nixos-vm";
      };
    };
}
