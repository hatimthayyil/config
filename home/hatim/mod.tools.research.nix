{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.zotero # reference management
    pkgs.qnotero # quick access to zotero references
    pkgs.monolith # archive web-page
    pkgs.xdot # graph viewer
    pkgs.gephi # Visualise and manipulate large graphs
    pkgs.datasette
    pkgs.wiki-tui # Wikipedia in CLI
  ];
}
