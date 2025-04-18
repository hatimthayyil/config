{
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.master.kicad # unstable is broken
  ];
}
