{
  pkgs,
  ...
}:

{
  packages = [ pkgs.git ];

  # languages.nix.enable = true;

  treefmt = {
    enable = true;
    config.programs = {
      nixfmt.enable = true;
    };
  };

  git-hooks.hooks = {
    shellcheck.enable = true;
    deadnix.enable = true;
    statix.enable = true;
  };
}
