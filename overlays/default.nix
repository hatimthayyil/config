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
      overlays = [ ];
    };
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [ ];
    };
  };

  master-packages = final: _prev: {
    master = import inputs.nixpkgs-master {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [ ];
    };
  };

  emacs-overlay-packages = final: prev: {
    emacs-overlay = inputs.emacs-overlay.overlay final prev;
  };

  nix4vscode-overlay = inputs.nix4vscode.overlays.forVscode;

  # The final combined overlay.
  default =
    final: prev:
    (stable-packages final prev)
    // (unstable-packages final prev)
    // (master-packages final prev)
    // (emacs-overlay-packages final prev)
    // (nix4vscode-overlay final prev);
in
{
  # Flake-parts expects overlays.default as an option
  flake.overlays = {
    inherit default;
  };
}
