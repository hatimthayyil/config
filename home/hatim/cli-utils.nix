{
  pkgs,
  ...
}: {
  programs = {
    # Utils
    btop.enable = true;
    fzf.enable = true;
    bat.enable = true;
    fastfetch.enable = true;

    # Search/finding
    fd.enable = true;

    # Session management
    tmux.enable = true;
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      options = [ "--cmd cd" ];
    };
    sesh.enable = true;
    fzf.tmux.enableShellIntegration = true; # needed for sesh
    ripgrep.enable = true;

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
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };

  home.packages = [
    pkgs.hyperfine # benchamarking tool
    pkgs.cloc # lines of code
    pkgs.tree # recursive listing of dirs
    pkgs.dust # better du (file sizes)
  ];
}
