{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.tools-research =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        home.packages = [
          pkgs.zotero
          pkgs.qnotero
          pkgs.monolith
          pkgs.suckit
          pkgs.xdot
          pkgs.gephi
          pkgs.cytoscape
          pkgs.neo4j
          pkgs.surrealist
          # pkgs.openrefine
          pkgs.datasette
          pkgs.wiki-tui
        ];
      };
    };
}
