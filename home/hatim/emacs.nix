{
  config,
  pkgs,
  ...
}: {
  programs.emacs = {
    enable = false;
    package = pkgs.emacs-overlay.emacs-git-pgtk;
    extraPackages = (epkgs: [
      epkgs.treesit-grammars.with-all-grammars
    ]);
  };

  programs.emacs-emx = {
    enable = true;
    package = pkgs.emacs-overlay.emacs-git-pgtk;
    treesitGrammars = [
      "all"
    ];
    localPath = "${config.home.homeDirectory}/src/emx";
  };
}
