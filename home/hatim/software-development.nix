{
  pkgs,
  ...
}: {
  programs = {
    # Direnv
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;

      config = {
        warn_timeout = "10m";
      };
    };

    jq.enable = true; # JSON processor

    gh = {
      enable = true;
      extensions = [
        pkgs.gh-s # search repos
        pkgs.gh-i # search issues
        pkgs.gh-f # fzf
        pkgs.gh-poi # clean up local branches
      ];
    };
    # GitHub dashboard (can be customised)
    gh-dash.enable = true;
  };

  home.packages = [
    # Dev
    pkgs.gnumake
    pkgs.just
    pkgs.curl
    pkgs.curlie # frontend for curl
    pkgs.shellcheck

    # Remote repo management
    pkgs.ghorg # clone entire org/user repos
    pkgs.github-backup # backup github

    # Reverse engineering
    pkgs.ghidra

    # Programming languages
    pkgs.stable.bend # Parallel computing
    pkgs.stable.hvm # Runtime for bend
  ];
}
