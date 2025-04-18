{
  pkgs,
  ...
}: {
  programs= {
    bash.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      history.size = 10000;
    };
    nushell.enable = true;
    oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      useTheme = "star";
    };
  };
}
