{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    userEmail = "hatim@thayyil.net";
    userName = "Hatim Thayyil";

    ignores = [
      # nix
      "*.drv"
      "result"
      # direnv
      ".direnv"
    ];

    difftastic = {
      enable = true;
    };

    extraConfig = {
      log.showSignature = true;
      init.defaultBranch = "main";
      pull.rebase = true;
    };

    aliases = {
      st = "status";
      co = "checkout";
      ad = "add";
      ap = "add -p";
      ci = "commit";
      rt = "restore";
      ri = "restore --staged";
      pl = "pull";
      br = "branch";
      sw = "!git branch | fzf | xargs git switch";
      cp =  "cherry-pick";
      pick = "!git log --online | fzf | cut -d' ' -f1 | xargs git cherry-pick";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };
      ui = {
        show-cryptographic-signatures = true;
        diff.tool = [ "difft" "--color=always" "$left" "$right"];
      };
    };
  };

  programs.mercurial = {
    enable = true;
    userName = config.programs.git.userName;
    userEmail = config.programs.git.userEmail;
  };

  home.packages = [
    pkgs.tig                    # TUI for git
    pkgs.cvs
    pkgs.mr                     # myrepos
  ];
}
