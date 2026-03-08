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
    ghostty = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    # foot.enable = true;
    # alacritty.enable = true;
  };

  home.packages = [
    # pkgs.st
  ];
}
