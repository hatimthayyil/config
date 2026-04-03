_: {
  # Bash
  programs.bash = {
    enable = true;
    shellAliases.s = "sesh connect $(sesh list --icons | fzf --ansi)"; # fuzzy-pick and connect to a tmux session; defined per-shell because sesh's builtin alias uses $(…) which breaks nushell
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases.s = "sesh connect $(sesh list --icons | fzf --ansi)"; # fuzzy-pick and connect to a tmux session; defined per-shell because sesh's builtin alias uses $(…) which breaks nushell

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # suggest commands from history as you type
      ];
    };
  };

  programs.fish = {
    enable = true;
    # TODO Add plugins, see https://github.com/jorgebucaran/awsm.fish
  };

  # Nu — sesh alias uses def instead of shellAliases because nushell can't parse $(…) subshells
  programs.nushell = {
    enable = true;
    extraConfig = ''
      def s [] { sesh connect (sesh list --icons | fzf --ansi) }
    '';
  };

  # Prompt — cross-shell, replaces powerlevel10k (unmaintained, zsh-only)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false; # no blank line before prompt
      palette = "tokyo-night"; # match tmux theme

      palettes.tokyo-night = {
        blue = "#7aa2f7";
        cyan = "#7dcfff";
        green = "#9ece6a";
        magenta = "#bb9af7";
        red = "#f7768e";
        yellow = "#e0af68";
        orange = "#ff9e64";
      };

      character = {
        success_symbol = "[❯](bold magenta)";
        error_symbol = "[❯](bold red)"; # red on non-zero exit
      };

      directory.style = "bold blue";
      git_branch.style = "bold magenta";
      git_status.style = "bold red";

      cmd_duration = {
        min_time = 2000; # only show for commands > 2s
        style = "bold yellow";
      };
    };
  };
}
