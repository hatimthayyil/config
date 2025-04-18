{
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.monolith # archive web-page
    pkgs.xdot # graph viewer
  ];
}
