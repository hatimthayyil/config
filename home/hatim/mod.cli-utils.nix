{
  pkgs,
  ...
}: {
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
    tmux.enable = true;
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      options = [ "--cmd cd" ];
    };
    sesh.enable = true;

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
