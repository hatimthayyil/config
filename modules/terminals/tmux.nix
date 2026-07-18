{ config, inputs, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.terminals =
    { pkgs, ... }:
    let
      tmuxModus = inputs.tmux-modus.packages.${pkgs.stdenv.hostPlatform.system}.default;
      modusToggle = pkgs.writeShellScript "modus-toggle" ''
        current="$(tmux show -gv @modus_theme)"
        if [ "$current" = operandi ]; then
          tmux set -g @modus_theme vivendi
        else
          tmux set -g @modus_theme operandi
        fi
      '';
      # flips the colors of every running kitty instance alongside the tmux
      # theme. Goes via kitty's remote-control sockets (see listen_on in
      # modules/terminals.nix) because tmux run-shell has no TTY, so the
      # default TTY transport of `kitten @` cannot reach kitty from here.
      # No-op when no kitty is running, e.g. under ghostty or SSH.
      kittyThemeToggle = pkgs.writeShellScript "kitty-theme-toggle" ''
        night="${pkgs.kitty-themes}/share/kitty-themes/themes/Modus_Vivendi.conf"
        day="${pkgs.kitty-themes}/share/kitty-themes/themes/Modus_Operandi.conf"
        for sock in /tmp/kitty-sock-*; do
          [ -S "$sock" ] || continue
          current_bg="$(${pkgs.kitty}/bin/kitten @ --to "unix:$sock" get-colors 2>/dev/null \
            | grep "^background " | tr -s ' ' | cut -d' ' -f2)"
          case "$current_bg" in
          "") continue ;; # stale socket left by a dead kitty
          "#ffffff") target="$night" ;;
          *) target="$day" ;;
          esac
          ${pkgs.kitty}/bin/kitten @ --to "unix:$sock" set-colors --all --configured "$target" 2>/dev/null || true
        done
      '';
    in
    {
      home-manager.users.${owner.username} = {
        programs.tmux = {
          enable = true;
          # default-shell drives tmux's *internal* job execution (status-line
          # #() commands, popups, plugin scripts) as well as new panes, so it
          # must stay POSIX (nu -c can't even parse `2>&1`). Panes still land
          # in nushell via `default-command` below.
          shell = "${pkgs.bash}/bin/bash";
          sensibleOnTop = true;
          mouse = true;
          keyMode = "vi";
          customPaneNavigationAndResize = false;
          baseIndex = 1;
          escapeTime = 10;
          historyLimit = 50000;
          terminal = "tmux-256color";
          disableConfirmationPrompt = true;
          prefix = "C-Space";
          clock24 = true;
          focusEvents = true;
          tmuxinator.enable = true;
          plugins = with pkgs.tmuxPlugins; [
            yank
            {
              plugin = vim-tmux-navigator;
              extraConfig = ''
                set -g @vim_navigator_mapping_left "M-h"
                set -g @vim_navigator_mapping_down "M-j"
                set -g @vim_navigator_mapping_up "M-k"
                set -g @vim_navigator_mapping_right "M-l"
                set -g @vim_navigator_mapping_prev ""
              '';
            }
            tmux-thumbs
            fzf-tmux-url
            extrakto
            open
            tmux-floax
            {
              plugin = resurrect;
              extraConfig = ''
                set -g @resurrect-strategy-nvim 'session'
                set -g @resurrect-capture-pane-contents 'on'
              '';
            }
            {
              plugin = tmuxModus;
              extraConfig = ''
                set -g @modus_theme 'vivendi'
              '';
            }
            # continuum must be last: it appends to status-right; any plugin
            # loaded after it that overwrites status-right (e.g. themes) will
            # silently disable autosave.
            {
              plugin = continuum;
              extraConfig = ''
                set -g @continuum-restore 'on'
                set -g @continuum-save-interval '1'
              '';
            }
          ];
          extraConfig = ''
            set -ag terminal-overrides ",xterm-256color:RGB"
            set -g extended-keys on

            # default-shell (bash) stays POSIX for tmux internals; panes
            # exec into nushell as the actual interactive shell
            set -g default-command "exec ${pkgs.nushell}/bin/nu -l"

            # tmux-sensible sets this to 5; 15 is plenty for a clock
            set -g status-interval 15

            bind v split-window -h -c "#{pane_current_path}"
            bind h split-window -v -c "#{pane_current_path}"
            bind c new-window -c "#{pane_current_path}"
            bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

            bind -r < swap-window -d -t -1
            bind -r > swap-window -d -t +1

            bind -n M-1 select-window -t 1
            bind -n M-2 select-window -t 2
            bind -n M-3 select-window -t 3
            bind -n M-4 select-window -t 4
            bind -n M-5 select-window -t 5
            bind -n M-6 select-window -t 6
            bind -n M-7 select-window -t 7
            bind -n M-8 select-window -t 8
            bind -n M-9 select-window -t 9

            bind -n M-Left select-pane -L
            bind -n M-Down select-pane -D
            bind -n M-Up select-pane -U
            bind -n M-Right select-pane -R

            bind -n M-S-Left resize-pane -L 5
            bind -n M-S-Down resize-pane -D 5
            bind -n M-S-Up resize-pane -U 5
            bind -n M-S-Right resize-pane -R 5

            bind -n M-z resize-pane -Z
            bind Space last-window
            bind BSpace switch-client -l
            bind S set-window-option synchronize-panes

            # toggle modus between vivendi (dark) and operandi (light) across
            # the tmux status line and kitty (if that's the host terminal)
            # overrides tmux's default clock-mode binding on this key, which is unused here
            bind t \
              run-shell ${modusToggle} \; \
              run-shell "${tmuxModus}/share/tmux-plugins/modus/modus.tmux" \; \
              run-shell ${kittyThemeToggle}

            set -g detach-on-destroy off
            set -g set-clipboard on
            set -g monitor-activity on
            set -g visual-activity off
            set -g renumber-windows on
            set -g status-position top
          '';
        };
      };
    };
}
