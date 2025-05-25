{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.stable.praat # phonetics, seems to be broken
  ];
}
