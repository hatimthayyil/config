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
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
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
        shells = [ pkgs.zsh ];
        localBinInPath = true;
        systemPackages = with pkgs; [
          vim
          wget
          git
          stable.nvtopPackages.nvidia
          stable.nvtopPackages.intel
        ];
      };

      users.defaultUserShell = pkgs.zsh;
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableGlobalCompInit = false; # home-manager handles compinit with caching
      };

      users.users.${owner.username} = {
        isNormalUser = true;
        description = owner.fullName;
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
        dates = "02:00";
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

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
}
