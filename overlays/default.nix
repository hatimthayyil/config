#
# This file defines overlays/custom modifications to upstream packages
#

{
  inputs,
  ...
}:
let
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [];
    };
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [];
    };
  };

  unstable-small-packages = final: _prev: {
    unstable-small = import inputs.nixpkgs-unstable-small {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [];
    };
  };

  master-packages = final: _prev: {
    master = import inputs.nixpkgs-master {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [];
    };
  };

  emacs-overlay-packages = final: prev: {
    emacs-overlay = (inputs.emacs-overlay.overlay final prev);
  };
in
  {
    default = final: prev:
      (stable-packages final prev)
      // (unstable-packages final prev)
      // (unstable-small-packages final prev)
      // (master-packages final prev)
      // (emacs-overlay-packages final prev);
  }
