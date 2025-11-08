{ inputs }:
final: prev: {
  # Firefox CSS Hacks:
  firefox-csshacks = prev.callPackage ./firefox-csshacks.nix { inherit inputs; };
}