_: {
  # Bash
  programs.bash.enable = true;

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;

    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';

    zplug = {
      enable = true;
      plugins = [
        {
          name = "zsh-users/zsh-autosuggestions";
        }
        {
          name = "romkatv/powerlevel10k";
          tags = [
            "as:theme"
            "depth:1"
          ];
        }
      ];
    };
  };

  home.file.".p10k.zsh" = {
    source = ./file.zsh.p10k.zsh;
    executable = true;
  };

  programs.fish = {
    enable = true;
    # TODO Add plugins, see https://github.com/jorgebucaran/awsm.fish
  };

  # Nu
  programs.nushell.enable = true;
}
