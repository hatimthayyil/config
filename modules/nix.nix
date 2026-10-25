{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.nix =
    { lib, pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        programs = {
          nh = {
            enable = true;
            clean.enable = true;
            flake = "/home/hatim/code/config";
          };
          nix-index = {
            enable = true;
            enableBashIntegration = false;
            enableNushellIntegration = false;
          };
          nix-index-database.comma.enable = true;
        };

        services.home-manager.autoUpgrade = {
          flakeDir = "/home/hatim/code/config";
          frequency = "3:15";
          useFlake = true;
        };

        # Nix writes a pack per download into its tarball cache and never
        # repacks it; every fetch scans all packs. The repo has no refs, so
        # anything that prunes or makes cruft packs (`git gc`, the
        # geometric-repack maintenance task) deletes the cache.
        # `repack --geometric` only merges packs and keeps every object.
        systemd.user = {
          services.nix-tarball-cache-repack = {
            Unit.Description = "Merge the packs of Nix's tarball cache";
            Service = {
              Type = "oneshot";
              Nice = 19;
              IOSchedulingClass = "idle";
              ExecStart = lib.getExe (
                pkgs.writeShellApplication {
                  name = "nix-tarball-cache-repack";
                  runtimeInputs = [ pkgs.git ];
                  text = ''
                    cache="''${XDG_CACHE_HOME:-$HOME/.cache}/nix/tarball-cache-v2"
                    [ -d "$cache/objects/pack" ] || exit 0
                    git -C "$cache" repack --geometric=2 -d --quiet
                  '';
                }
              );
            };
          };
          timers.nix-tarball-cache-repack = {
            Unit.Description = "Merge the packs of Nix's tarball cache daily";
            Timer = {
              OnCalendar = "daily";
              Persistent = true;
            };
            Install.WantedBy = [ "timers.target" ];
          };
        };

        home.packages = [
          # Cache
          pkgs.cachix
          pkgs.attic-client
          inputs.niks3.packages.${pkgs.system}.niks3
          inputs.nix-fast-build.packages.${pkgs.system}.default

          # Dev
          pkgs.nixd
          pkgs.nil
          pkgs.nvd
          pkgs.manix
          pkgs.nix-health
          pkgs.deadnix
          pkgs.statix
          pkgs.nix-update
          pkgs.nix-diff
          pkgs.nix-du
          pkgs.nix-init
          pkgs.nix-melt
          pkgs.nix-tree
          pkgs.nixfmt

          pkgs.lorri

          pkgs.nix-output-monitor
          pkgs.nix-forecast
        ];
      };
    };
}
