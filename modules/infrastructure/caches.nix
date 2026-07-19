{ lib, config, ... }:
{
  options.caches = {
    substituters = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      readOnly = true;
    };
    trusted-public-keys = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      readOnly = true;
    };
  };

  config = {
    caches = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://helix.cachix.org"
        "https://cache.thayyil.net"
        # Mic92's personal cache; niks3 CI publishes builds there.
        "https://cache.thalheim.io"
        "https://cache.numtide.com"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "cache.thayyil.net:OCyxFK7dzZQPwvpWU0SPSqjH9cpxTfREy/dIJSLRClM="
        "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };

    # Exposed as a flake output so CI reads the same list:
    # nix eval --json .#lib.caches
    flake.lib.caches = {
      inherit (config.caches) substituters trusted-public-keys;
    };
  };
}
