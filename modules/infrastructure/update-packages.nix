{ inputs, config, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ config.flake.overlays.default ];
      };

      inherit (pkgs) lib;

      localPackages = import ../../pkgs/overlay.nix { inherit inputs; } pkgs pkgs;

      updatable = lib.filterAttrs (_: p: lib.isDerivation p && p ? updateScript) localPackages;

      invoke =
        name: package:
        let
          command = lib.toList (package.updateScript.command or package.updateScript);
        in
        ''
          echo "==> ${name} ${package.version or ""}"
          ${lib.escapeShellArgs (map toString command)} ${lib.escapeShellArg name}
        '';
    in
    {
      packages.update-packages = pkgs.writeShellApplication {
        name = "update-packages";
        runtimeInputs = [
          pkgs.nix
          pkgs.git
        ];
        text = lib.concatStringsSep "\n" (lib.mapAttrsToList invoke updatable);
      };
    };
}
