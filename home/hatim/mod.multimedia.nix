{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.imagemagick
    pkgs.poppler
    pkgs.mediainfo
    pkgs.stable.calibre
    pkgs.stable.calibre-web
  ];
}
