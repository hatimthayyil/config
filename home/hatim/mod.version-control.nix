{
  config,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    settings.user = {
      email = "hatim@thayyil.net";
      name = "Hatim Thayyil";
    };

    lfs.enable = true;

    ignores = [
      # nix
      "*.drv"
      "result"
      # direnv
      ".direnv"
    ];

    settings = {
      log.showSignature = true;
      init.defaultBranch = "main";
      pull.rebase = true;
    };

    settings.alias = {
      st = "status";
      ld = "log --patch --ext-diff";
      co = "checkout";
      ad = "add";
      ap = "add -p";
      dt = "diff";
      di = "diff --cached";
      ci = "commit";
      rt = "restore";
      ri = "restore --staged";
      pl = "pull";
      br = "branch";
      sw = "!git branch | fzf | xargs git switch";
      cp = "cherry-pick";
      pick = "!git log --online | fzf | cut -d' ' -f1 | xargs git cherry-pick";
    };
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        inherit (config.programs.git.settings.user) name;
        inherit (config.programs.git.settings.user) email;
      };
      ui = {
        show-cryptographic-signatures = true;
        diff.tool = [
          "difft"
          "--color=always"
          "$left"
          "$right"
        ];
      };
    };
  };

  programs.mercurial = {
    enable = true;
    userName = config.programs.git.settings.user.name;
    userEmail = config.programs.git.settings.user.email;
  };

  programs.lazygit.enable = true;
  programs.gitui.enable = true;

  home.packages = [
    pkgs.tig # TUI for git
    pkgs.cvs
    pkgs.mr # myrepos

    # Git extensions
    pkgs.git-machete
    pkgs.git-imerge
    pkgs.git-annex
  ];
}
