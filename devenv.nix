{
  pkgs,
  ...
}:

{
  packages = [
    pkgs.git
    pkgs.just
  ];

  languages.javascript = {
    enable = true;
    directory = "./infra/niks3";
    pnpm = {
      enable = true;
      install.enable = true;
    };
  };

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
