{
  pkgs,
  ...
}:
{
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

    # Github
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

    # Python
    uv.enable = true;

    # Javascript
    npm.enable = true;
    bun.enable = true;
  };

  home.packages = [
    # Dev
    pkgs.gnumake
    pkgs.just
    pkgs.curl
    pkgs.curlie # frontend for curl
    pkgs.shellcheck
    pkgs.distrobox
    pkgs.devenv
    pkgs.copier
    pkgs.mprocs # TUI for running long processes
    pkgs.nix-playground # Nix playground

    # Remote repo management
    pkgs.ghorg # clone entire org/user repos
    pkgs.github-backup # backup github

    # Reverse engineering
    #LEAN pkgs.ghidra

    # Programming languages
    #BROKEN pkgs.stable.bend # Parallel computing
    #BROKEN pkgs.stable.hvm # Runtime for bend
    pkgs.rustycli # Rust playground in CLI
    pkgs.rustup # Needs a C cimpiler
    pkgs.steel # Lisp with Rust integration
    pkgs.clang # C/C++ compiler
    pkgs.lldb # LLVM debugger
    pkgs.jupyter-all # NixOS has a jupyter service

    # Misc
    pkgs.exercism # CLI for exercism.org
    pkgs.rusty-man # Rust docs in CLI

    # Docker
    pkgs.oxker # Docker CLI tool for managing containers
  ];
}
