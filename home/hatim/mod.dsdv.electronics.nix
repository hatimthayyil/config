{
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.unstable.kicad # unstable is broken
  ];
}
