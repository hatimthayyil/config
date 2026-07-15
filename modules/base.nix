{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
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
        inputs.nix-flake-upgrade.nixosModule."x86_64-linux"
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
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://helix.cachix.org"
            "https://cache.thayyil.net"
            # Mic92's personal cache; niks3 CI publishes builds there.
            "https://cache.thalheim.io"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
            "cache.thayyil.net:OCyxFK7dzZQPwvpWU0SPSqjH9cpxTfREy/dIJSLRClM="
            "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
          ];
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

      system.autoUpgradeFlake = {
        enable = true;
        dates = "03:15";
        allowReboot = true;
        flake-dir = "${config.users.users.${owner.username}.home}/code/config";
        user = owner.username;
        nix-flake-upgrade-flags = [
          "--update-lock-file"
          "--push"
          "--os"
          "--os-only-when-changed"
        ];
      };

      # git (called by nix flake update) needs bash in PATH for hooks/subcommands
      systemd.services.flake-upgrade.path = [ pkgs.bash ];

      # Headless bot commits must not sign (service can't sign interactively).
      systemd.services.flake-upgrade.environment = {
        GIT_CONFIG_COUNT = "1";
        GIT_CONFIG_KEY_0 = "commit.gpgsign";
        GIT_CONFIG_VALUE_0 = "false";
      };

      # gpg-agent kept for pass (GPG) only; SSH uses a dedicated ssh-agent.
      # Removed at GPG retirement.
      programs.gnupg.agent = {
        enable = true;
      };
    };
}
