# Web design and development tools

{
  pkgs,
  ...
}:
{
  home.packages = [
    # Http
    pkgs.httpie
    pkgs.httplab

    # UI/UX
    #LEAN pkgs.figma-linux
  ];
}
