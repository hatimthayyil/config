{
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.monolith # archive web-page
    pkgs.xdot # graph viewer
    pkgs.gephi # Visualise and manipulate large graphs
  ];
}
