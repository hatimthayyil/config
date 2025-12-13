# Minimal template for a Dioxus Web project
# See full reference at https://devenv.sh/reference/options/

{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  # NOTE Remove once wasm-bindgen-cli 0.2.106 is available in nixpkgs
  toolchain = pkgs.rust-bin.stable.latest.default.override {
    targets = [ "wasm32-unknown-unknown" ];
  };
  rustPlatform = pkgs.makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  };
  wasm-bindgen-cli = pkgs.buildWasmBindgenCli rec {
    src = pkgs.fetchCrate {
      pname = "wasm-bindgen-cli";
      version = "0.2.106";
      hash = "sha256-M6WuGl7EruNopHZbqBpucu4RWz44/MSdv6f0zkYw+44=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      inherit (src) pname version;
      hash = "sha256-ElDatyOwdKwHg3bNH/1pcxKI7LXkhsotlDPQjiLHBwA=";
    };
  };
in
{
  overlays = [
    inputs.rust-overlay.overlays.default
  ];

  packages = [
    pkgs.dioxus-cli
    wasm-bindgen-cli
  ];

  languages.rust = {
    enable = true;
    channel = "stable";
    targets = [ "wasm32-unknown-unknown" ];
  };

  enterShell = ''
    dx --version
    rustc --version
  '';

  treefmt = {
    enable = true;
    config.programs = {
      rustfmt.enable = true;
      taplo.enable = true;
      nixpkgs-fmt.enable = true;
    };
  };

  git-hooks.hooks = {
    treefmt.enable = true;
    clippy = {
      enable = true;
      settings = {
        allFeatures = true;
        offline = false;
        denyWarnings = true;
        extraArgs = "--all-targets";
      };
    };
  };
}
