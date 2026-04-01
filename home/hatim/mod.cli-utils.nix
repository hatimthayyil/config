{
  pkgs,
  ...
}:
{
  programs = {
    # Utils
    btop.enable = true;
    bat.enable = true;
    fastfetch.enable = true;

    # Search/finding
    fd.enable = true;
    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true; # needed for sesh
    };
    ripgrep = {
      enable = true;
      arguments = [
        "--max-columns-preview"
        "--colors=line:style:bold"
        "--smart-case"
      ];
    };
    ripgrep-all = {
      enable = true;
    };
    skim = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    # Session management
    tmux = {
      enable = true;
      sensibleOnTop = true; # load tmux-sensible defaults first (better escape, history, etc.)
      mouse = true; # click panes, scroll, resize with mouse
      keyMode = "vi"; # vi keys in copy mode and status line
      customPaneNavigationAndResize = false; # we define our own Alt+hjkl bindings below
      baseIndex = 1; # windows and panes start at 1 not 0
      escapeTime = 0; # no delay after pressing Escape (important for vim)
      historyLimit = 50000; # scrollback lines per pane
      terminal = "tmux-256color"; # enables 256 color support
      disableConfirmationPrompt = true; # kill pane/window without "are you sure?"
      prefix = "C-Space"; # main modifier key (Ctrl+Space)
      clock24 = true; # 24-hour clock in clock mode (prefix+t)
      focusEvents = true; # lets vim/neovim detect when you switch panes
      tmuxinator.enable = true; # declarative session layouts via YAML files
      plugins = with pkgs.tmuxPlugins; [
        yank # copy to system clipboard in copy mode
        vim-tmux-navigator # Ctrl+hjkl moves between vim splits AND tmux panes seamlessly
        tmux-thumbs # prefix+Space: vimium-style hints to copy visible text (urls, paths, hashes)
        fzf-tmux-url # prefix+u: fzf picker for all visible URLs
        extrakto # prefix+tab: fuzzy search any text on screen, insert or copy
        open # in copy mode, 'o' opens selected file/url in editor/browser
        tmux-floax # prefix+p: toggle a floating scratch pane
        {
          plugin = resurrect; # manually save/restore full sessions
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session' # restore neovim sessions too
            set -g @resurrect-capture-pane-contents 'on' # save pane visible text
          '';
        }
        {
          plugin = continuum; # auto-save/restore on top of resurrect
          extraConfig = ''
            set -g @continuum-restore 'on' # auto-restore last session on tmux start
            set -g @continuum-save-interval '1' # save every 1 minute
          '';
        }
        {
          plugin = tokyo-night-tmux;
          extraConfig = ''
            set -g @tokyo-night-tmux_theme 'night' # darkest variant
            set -g @tokyo-night-tmux_transparent 1 # inherit terminal background
            set -g @tokyo-night-tmux_window_id_style 'digital' # 7-segment display digits
            set -g @tokyo-night-tmux_pane_id_style 'hsquare' # hollow square numbers
            set -g @tokyo-night-tmux_zoom_id_style 'dsquare' # double-square when zoomed
            set -g @tokyo-night-tmux_show_datetime 1 # show date/time in status bar
            set -g @tokyo-night-tmux_date_format 'DMY' # day/month/year
            set -g @tokyo-night-tmux_time_format '24H' # 24-hour time
            set -g @tokyo-night-tmux_show_path 1 # show current directory in status bar
            set -g @tokyo-night-tmux_path_format 'relative' # ~/code instead of /home/user/code
            set -g @tokyo-night-tmux_show_git 1 # show branch, changes, sync status
          '';
        }
      ];
      extraConfig = ''
        set -ag terminal-overrides ",xterm-256color:RGB" # fix true color in terminals that report as xterm

        bind v split-window -h -c "#{pane_current_path}" # prefix+v: vertical split (left/right)
        bind h split-window -v -c "#{pane_current_path}" # prefix+h: horizontal split (top/bottom)
        bind c new-window -c "#{pane_current_path}" # prefix+c: new window in same directory
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded" # prefix+r: reload config

        bind -r < swap-window -d -t -1 # prefix+<: move window left (-r = repeatable)
        bind -r > swap-window -d -t +1 # prefix+>: move window right

        bind -n M-1 select-window -t 1 # Alt+1-9: jump to window (no prefix needed)
        bind -n M-2 select-window -t 2
        bind -n M-3 select-window -t 3
        bind -n M-4 select-window -t 4
        bind -n M-5 select-window -t 5
        bind -n M-6 select-window -t 6
        bind -n M-7 select-window -t 7
        bind -n M-8 select-window -t 8
        bind -n M-9 select-window -t 9

        bind -n M-h select-pane -L # Alt+hjkl: navigate panes (no prefix)
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R
        bind -n M-Left select-pane -L # Alt+arrows: same but with arrow keys
        bind -n M-Down select-pane -D
        bind -n M-Up select-pane -U
        bind -n M-Right select-pane -R

        bind -n M-S-Left resize-pane -L 5 # Alt+Shift+arrows: resize panes by 5 cells
        bind -n M-S-Down resize-pane -D 5
        bind -n M-S-Up resize-pane -U 5
        bind -n M-S-Right resize-pane -R 5

        bind -n M-z resize-pane -Z # Alt+z: toggle pane zoom (no prefix)
        bind Space last-window # prefix+Space: jump to previous window
        bind S set-window-option synchronize-panes # prefix+S: type in all panes at once

        set -g detach-on-destroy off # switch to next session on kill instead of detaching
        set -g set-clipboard on # OSC 52: system clipboard works even over SSH
        set -g monitor-activity on # highlight windows with new activity in status bar
        set -g visual-activity off # but don't show a message overlay about it
        set -g renumber-windows on # closing window 2 of 4 renumbers 3,4 to 2,3
        set -g status-position top # status bar at top of screen
      '';
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    sesh.enable = true;
    zellij = {
      enable = true;
      enableZshIntegration = false;
      settings = {
        copy_command = "wl-copy";
      };
    };

    # File/Directory navigation
    lsd = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    broot = {
      enable = false;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };

  home.packages = [
    pkgs.hyperfine # benchamarking tool
    pkgs.cloc # lines of code
    pkgs.tokei # lines of code
    pkgs.tree # recursive listing of dirs
    pkgs.dust # better du (file sizes)
    pkgs.ncdu # ncurses disk usage analyzer
    pkgs.fselect # Find files with SQL-like prompt.
    pkgs.sd # sed alternative
    pkgs.scooter # find and replace tool
    pkgs.kondo # clean up build artifacts
  ];
}
