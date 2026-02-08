{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.shells;
in
{
  options.hatim.modules.shells = {
    enable = lib.mkEnableOption "shell configurations";
    bash.enable = lib.mkEnableOption "bash shell" // {
      default = true;
    };
    zsh.enable = lib.mkEnableOption "zsh shell" // {
      default = true;
    };
    fish.enable = lib.mkEnableOption "fish shell" // {
      default = true;
    };
    nushell.enable = lib.mkEnableOption "nushell shell" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # Bash
    programs.bash.enable = lib.mkIf cfg.bash.enable true;

    # Zsh
    programs.zsh = lib.mkIf cfg.zsh.enable {
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

    # Fish
    programs.fish = lib.mkIf cfg.fish.enable {
      enable = true;
      # TODO Add plugins, see https://github.com/jorgebucaran/awsm.fish
    };

    # Nushell
    programs.nushell = lib.mkIf cfg.nushell.enable {
      enable = true;
    };
  };
}
