{
  pkgs,
  ...
}:
{
  # TODO Wine-compatible Microcap is provided by
  # https://github.com/emmanuelrosa/erosanix
  home.packages = [
    # pkgs.stable.kicad-small # unstable is broken manage imperatively
  ];
}
