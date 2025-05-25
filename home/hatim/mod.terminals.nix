{
  pkgs,
  ...
}:
{
  programs = {
    kitty = {
      enable = true;
      shellIntegration.enableBashIntegration = true;
      shellIntegration.enableZshIntegration = true;
    };
    foot.enable = true;
    alacritty.enable = true;
  };

  home.packages = [
    pkgs.st
  ];
}
