{ inputs, ... }:
let
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  unstable-small-packages = final: _prev: {
    unstableSmall = import inputs.nixpkgs-unstable-small {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  # master-packages = final: _prev: {
  #   master = import inputs.nixpkgs-master {
  #     inherit (final.stdenv.hostPlatform) system;
  #     config.allowUnfree = true;
  #   };
  # };

  emacs-overlay-packages = final: prev: {
    emacs-overlay = inputs.emacs-overlay.overlay final prev;
  };

  nix4vscode-overlay = inputs.nix4vscode.overlays.forVscode;

  firefox-addons-overlay = inputs.nix-firefox-addons.overlays.default;

  claude-desktop-overlay = inputs.claude-desktop.overlays.default;

  # FIXME: remove after throttled service unit fix lands in unstable
  throttled-fix-overlay = final: _prev: {
    inherit (inputs.nixpkgs-unstable-small.legacyPackages.${final.stdenv.hostPlatform.system})
      throttled
      ;
  };

  default =
    final: prev:
    (stable-packages final prev)
    // (unstable-packages final prev)
    // (unstable-small-packages final prev)
    # // (master-packages final prev)
    // (emacs-overlay-packages final prev)
    // (nix4vscode-overlay final prev)
    // (firefox-addons-overlay final prev)
    // (claude-desktop-overlay final prev)
    // (throttled-fix-overlay final prev);
in
{
  flake.overlays = {
    inherit default;
  };
}
