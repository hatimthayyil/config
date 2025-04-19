{
  pkgs,
  ...
}: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-overlay.emacs-git-pgtk;
    extraPackages = (epkgs: [
      epkgs.treesit-grammars.with-all-grammars
    ]);
  };
}
