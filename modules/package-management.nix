_: {
  flake.modules.nixos.package-management =
    { pkgs, options, ... }:
    {
      services.guix = {
        enable = true;
        gc.enable = true;
        gc.extraArgs = [
          "--delete-generations=1m"
          "--free-space=25G"
          "--optimize"
        ];
        gc.dates = "03:15";
        substituters.urls = [
          "https://ci.guix.gnu.org"
          "https://bordeaux.guix.gnu.org"
          "https://berlin.guix.gnu.org"
          "https://substitutes.nonguix.org"
          "https://guix.bordeaux.inria.fr"
        ];
        substituters.authorizedKeys = options.services.guix.substituters.authorizedKeys.default ++ [
          ../hosts/files/guix-substitutes-signing-key-nonguix.pub
          ../hosts/files/guix-substitutes-signing-key-inria.pub
        ];
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };

      services.flatpak.enable = true;

      programs.appimage = {
        enable = true;
        binfmt = true;
        package = pkgs.appimage-run.override {
          extraPkgs = pkgs: [
            pkgs.webkitgtk_4_1
            pkgs.libsoup_3
          ];
        };
      };
    };
}
