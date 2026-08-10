{ lib, config, ... }:
let
  inherit (config.caches) registry;
in
{
  options.caches = {
    registry = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            url = lib.mkOption { type = lib.types.singleLineStr; };
            key = lib.mkOption { type = lib.types.singleLineStr; };
          };
        }
      );
      readOnly = true;
    };
    select = lib.mkOption {
      type = lib.types.functionTo (lib.types.attrsOf (lib.types.listOf lib.types.singleLineStr));
      readOnly = true;
    };
    public = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.singleLineStr);
      readOnly = true;
    };
  };

  config = {
    caches = {
      registry = {
        nixos = {
          url = "https://cache.nixos.org";
          key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
        };
        nix-community = {
          url = "https://nix-community.cachix.org";
          key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
        };
        helix = {
          url = "https://helix.cachix.org";
          key = "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs=";
        };
        thayyil = {
          url = "https://cache.thayyil.net";
          key = "cache.thayyil.net:OCyxFK7dzZQPwvpWU0SPSqjH9cpxTfREy/dIJSLRClM=";
        };
        thalheim = {
          url = "https://cache.thalheim.io";
          key = "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc=";
        };
        numtide = {
          url = "https://cache.numtide.com";
          key = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
        };
        # Selected by the nixbuild group, never by `public`: the CI runner
        # builds into this store and the account must not substitute from itself.
        # Explicit priority: ssh stores serve no nix-cache-info, so they default
        # to 0 and outrank every HTTP cache.
        nixbuild = {
          url = "ssh://eu.nixbuild.net?priority=100";
          key = "nixbuild.net/ZUVWVI-1:m/gkAtGRxAqjw8dX8YuIq/GCAAx+rHi13FcsROFYkX4=";
        };
      };

      select = names: {
        substituters = map (name: registry.${name}.url) names;
        trusted-public-keys = map (name: registry.${name}.key) names;
      };

      public = config.caches.select [
        "nixos"
        "nix-community"
        "helix"
        "thayyil"
        "thalheim"
        "numtide"
      ];
    };

    # Exposed as a flake output so CI reads the same list:
    # nix eval --json .#lib.caches
    flake.lib.caches = config.caches.public;
  };
}
