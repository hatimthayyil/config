{ lib, ... }:
let
  # lib = import <nixpkgs/lib>;
  # Find all subdirectories that contain a flake.nix
  entries = builtins.readDir ./.;
  directories = lib.attrsets.filterAttrs (name: type: type == "directory") entries;

  makeTemplate = name: {
    path = ./."${name}";
    description = let
      flake = import (./. + "/${name}/devenv.nix");
    in flake.description or "Template for ${name}";
  };
in
{
  lib.attrsets.mapAttrs (name: _: makeTemplate name) directories
}
