{ config, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.cli-utils =
    { pkgs, ... }:
    let
      tokyoNightToggle = pkgs.writeShellScript "tokyo-night-toggle" ''
        current="$(tmux show -gv @tokyo-night-tmux_theme)"
        if [ "$current" = day ]; then
          tmux set -g @tokyo-night-tmux_theme night
        else
          tmux set -g @tokyo-night-tmux_theme day
        fi
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
              plugin = tokyo-night-tmux;
              extraConfig = ''
                set -g @tokyo-night-tmux_theme 'night'
                set -g @tokyo-night-tmux_transparent 0
                set -g @tokyo-night-tmux_window_id_style 'digital'
                set -g @tokyo-night-tmux_pane_id_style 'hsquare'
                set -g @tokyo-night-tmux_zoom_id_style 'dsquare'
                set -g @tokyo-night-tmux_show_datetime 1
                set -g @tokyo-night-tmux_date_format 'DMY'
                set -g @tokyo-night-tmux_time_format '24H'
                set -g @tokyo-night-tmux_show_path 1
                set -g @tokyo-night-tmux_path_format 'relative'
                set -g @tokyo-night-tmux_show_git 1
                # explicitly off: the "unset" state is NOT off (script only
                # skips on the literal string "0"), so left unset it fires
                # 3 gh api calls (pr list/status, issue list) every ~20s
                set -g @tokyo-night-tmux_show_wbg 0
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

            # tmux-sensible sets this to 5, which is too aggressive for a
            # status line that shells out to git on every tick
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

            # toggle tokyo-night-tmux between its dark (night) and light (day) variants
            # overrides tmux's default clock-mode binding on this key, which is unused here
            bind t \
              run-shell ${tokyoNightToggle} \; \
              run-shell "${pkgs.tmuxPlugins.tokyo-night-tmux}/share/tmux-plugins/tokyo-night-tmux/tokyo-night.tmux"

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
