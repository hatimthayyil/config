{ inputs, ... }:
let
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
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

  agents-nix-overlay = inputs.agents-nix.overlays.default;

  # FIXME: remove after throttled service unit fix lands in unstable
  throttled-fix-overlay = final: _prev: {
    inherit (inputs.nixpkgs-unstable-small.legacyPackages.${final.stdenv.hostPlatform.system})
      throttled
      ;
  };

  # FIXME: remove after NixOS/nixpkgs#568692 is fixed
  zotero-fix-overlay = final: _prev: {
    inherit (inputs.nixpkgs-zotero.legacyPackages.${final.stdenv.hostPlatform.system})
      zotero
      ;
  };

  # FIXME: remove after nixpkgs filen-desktop stops resolving rclone via Electron's resourcesPath
  filen-desktop-fix-overlay = _final: prev: {
    filen-desktop = prev.filen-desktop.overrideAttrs (old: {
      postPatch = old.postPatch + ''
        substituteInPlace src/lib/rclone/binary.ts \
          --replace-fail 'process.resourcesPath, "app.asar.unpacked"' "\"$out/share/filen-desktop/resources/app.asar.unpacked\""
      '';
    });
  };

  local-packages = import ../pkgs/overlay.nix { inherit inputs; };

  default =
    final: prev:
    (stable-packages final prev)
    // (unstable-small-packages final prev)
    # // (master-packages final prev)
    // (emacs-overlay-packages final prev)
    // (nix4vscode-overlay final prev)
    // (firefox-addons-overlay final prev)
    // (claude-desktop-overlay final prev)
    // (agents-nix-overlay final prev)
    // (throttled-fix-overlay final prev)
    // (zotero-fix-overlay final prev)
    // (filen-desktop-fix-overlay final prev)
    // (local-packages final prev);
in
{
  flake.overlays = {
    inherit default;
  };
}
