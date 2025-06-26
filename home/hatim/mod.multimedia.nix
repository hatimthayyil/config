{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.imagemagick
    pkgs.poppler
    pkgs.mediainfo
    pkgs.calibre
    pkgs.calibre-web
  ];
}
