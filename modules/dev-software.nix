{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.dev-software =
    { pkgs, ... }:
    {
      # NixOS: dynamic linking for unpackaged binaries
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        libxcb
        libGL
        glib
        dbus
      ];

      # HM: development tools and runtimes
      home-manager.users.${owner.username} = {
        programs = {
          direnv = {
            enable = true;
            nix-direnv.enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = true;
            config.warn_timeout = "10m";
          };

          jq.enable = true;

          gh = {
            enable = true;
            extensions = [
              pkgs.gh-s
              pkgs.gh-i
              pkgs.gh-f
              pkgs.gh-poi
            ];
          };
          gh-dash.enable = true;

          mise = {
            enable = true;
            package = pkgs.mise;
          };

          devenv = {
            enable = true;
            package = pkgs.devenv;
            enableBashIntegration = true;
            enableNushellIntegration = false;
          };

          go.enable = true;
          uv.enable = true;
          npm.enable = true;
          bun.enable = true;
          awscli.enable = true;
        };

        home.packages = [
          # Dev
          pkgs.gnumake
          pkgs.just
          pkgs.curl
          pkgs.curlie
          pkgs.openssl
          pkgs.shellcheck
          # pkgs.secretspec # Included with devenv.
          pkgs.devbox
          pkgs.copier
          pkgs.mprocs
          pkgs.nix-playground

          # Databases
          pkgs.sqlite-interactive
          pkgs.sqlitebrowser
          pkgs.dolt

          # Remote repo management
          pkgs.ghorg
          pkgs.github-backup

          # Programming languages
          pkgs.rustycli
          pkgs.rustup
          pkgs.steel
          pkgs.clang
          pkgs.conda
          inputs.bend.packages.${pkgs.system}.default
          pkgs.cargo-seek

          # Misc
          pkgs.exercism
          pkgs.rusty-man

          # Docker
          pkgs.oxker
        ];
      };
    };
}
