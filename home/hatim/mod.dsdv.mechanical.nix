{
  pkgs,
  ...
}:
{
  home.packages = [
    # CAD Software
    pkgs.freecad

    # 3D Printers
    pkgs.bambu-studio
  ];
}
