{
  options,
  ...
}:
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
      ./files/guix-substitutes-signing-key-nonguix.pub
      ./files/guix-substitutes-signing-key-inria.pub
    ];
  };

  services.flatpak.enable = true;
}
