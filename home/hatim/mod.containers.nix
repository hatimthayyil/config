{ pkgs, ... }:
{
  programs.distrobox.enable = true;

  home.packages = with pkgs; [
    wineWowPackages.stable # support 32bit and 64bit
    winetricks
  ];
}
