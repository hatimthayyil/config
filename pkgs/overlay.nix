{ inputs }:
_final: prev: {
  # Firefox CSS Hacks:
  firefox-csshacks = prev.callPackage ./firefox-csshacks.nix { inherit inputs; };
  zed-preview = prev.callPackage ./zed-preview.nix { };
}
