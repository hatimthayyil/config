{
  pkgs,
  ...
}:
{
  # TODO Wine-compatible Microcap is provided by
  # https://github.com/emmanuelrosa/erosanix
  home.packages = [
    pkgs.unstable.kicad # unstable is broken
  ];
}
