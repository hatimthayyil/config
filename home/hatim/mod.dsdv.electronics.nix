{
  pkgs,
  ...
}:
{
  # TODO Wine-compatible Microcap is provided by
  # https://github.com/emmanuelrosa/erosanix
  home.packages = [
    pkgs.stable.kicad # unstable is broken
  ];
}
