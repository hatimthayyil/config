{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.shells = _: {
    home-manager.users.${owner.username} = {
      # Bash
      programs.bash = {
        enable = true;
        shellAliases.s = "sesh connect $(sesh list --icons | fzf --ansi)"; # fuzzy-pick and connect to a tmux session; defined per-shell because sesh's builtin alias uses $(…) which breaks nushell
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

      # Prompt — cross-shell
      programs.starship = {
        enable = true;
        enableBashIntegration = true;
        enableNushellIntegration = true;
        enableFishIntegration = true;
        settings = {
          add_newline = false; # no blank line before prompt

          # no fixed palette: named colors resolve through the terminal's
          # ANSI table, so the prompt follows the active theme (and the
          # light/dark toggle) instead of pinning one theme's hex values

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
    };
  };
}
