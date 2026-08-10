{ config, ... }:
let
  inherit (config.caches) registry;
in
{
  flake.modules.nixos.nixbuild = {
    nix = {
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

      # Merges with the public list in base; a host gets the builder and the
      # substituter together or not at all.
      settings = {
        substituters = [ registry.nixbuild.url ];
        trusted-public-keys = [ registry.nixbuild.key ];
      };
    };
  };
}
