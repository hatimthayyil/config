{
  config,
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
      ];

      # HM: development tools and runtimes
      home-manager.users.${owner.username} = {
        programs = {
          direnv = {
            enable = true;
            nix-direnv.enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
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
            package = pkgs.unstable.mise;
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
          pkgs.shellcheck
          pkgs.unstable.devenv
          pkgs.unstable.secretspec
          pkgs.devbox
          pkgs.copier
          pkgs.mprocs
          pkgs.nix-playground
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

          # Misc
          pkgs.exercism
          pkgs.rusty-man

          # Docker
          pkgs.oxker

          # Desktop App Dev
          pkgs.pkg-config
          pkgs.fontconfig
          pkgs.gobject-introspection
          pkgs.libxcb
          pkgs.libxkbcommon
          pkgs.at-spi2-atk
          pkgs.atkmm
          pkgs.cairo
          pkgs.glib
          pkgs.gtk3
          pkgs.harfbuzz
          pkgs.librsvg
          pkgs.libsoup_3
          pkgs.pango
          pkgs.webkitgtk_4_1
          pkgs.openssl
          pkgs.dbus
          pkgs.zlib
          pkgs.zstd
        ];
      };
    };
}
