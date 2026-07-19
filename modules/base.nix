{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner caches;
in
{
  flake.modules.nixos.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ];

      nix = {
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
        nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

        distributedBuilds = true;
        buildMachines = [
          {
            hostName = "eu.nixbuild.net";
            system = "x86_64-linux";
            maxJobs = 100;
            supportedFeatures = [
              "benchmark"
              "big-parallel"
            ];
          }
        ];

        settings = {
          connect-timeout = 5;
          log-lines = 25;
          min-free = 128000000;
          max-free = 1000000000;
          trusted-users = [ "@wheel" ];
          auto-optimise-store = true;
          warn-dirty = false;
          allow-import-from-derivation = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          inherit (caches) substituters trusted-public-keys;
        };

        gc = {
          automatic = true;
          dates = [ "3:15" ];
          options = "--delete-older-than 3d";
        };
      };

      nixpkgs = {
        overlays = [ inputs.self.overlays.default ];
        config.allowUnfree = true;
      };

      system.stateVersion = "24.11";

      environment = {
        shells = [
          pkgs.bash
          pkgs.nushell
        ];
        localBinInPath = true;
        systemPackages = with pkgs; [
          vim
          wget
          git
          stable.nvtopPackages.full
        ];
      };

      users.defaultUserShell = pkgs.nushell;

      users.users.${owner.username} = {
        isNormalUser = true;
        description = owner.fullName;
        shell = pkgs.bash;
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
        ];
        packages = with pkgs; [
          kdePackages.kate
        ];
      };

      # gpg-agent kept for pass (GPG) only; SSH uses a dedicated ssh-agent.
      # Removed at GPG retirement.
      programs.gnupg.agent = {
        enable = true;
      };
    };
}
