{
  pkgs,
  ...
}:
{
  home.packages = [
    # CAD Software
    pkgs.freecad

    # 3D Printers
    #pkgs.bambu-studio #FIXME depends on libsoup-2 (through webkitgtk2) which is EOL. (see https://github.com/NixOS/nixpkgs/commit/fd2e12be0b679dd7c066f16b50a4d3d773b309a1)
  ];
}
