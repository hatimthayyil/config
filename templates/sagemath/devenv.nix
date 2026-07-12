# Development environment for Python with uv
#
# See full reference at https://devenv.sh/reference/options/

{
  pkgs,
  ...
}:

{
  packages = with pkgs; [
    sage
  ];

  languages.python = {
    enable = true;
    venv.enable = true;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  # https://devenv.sh/basics/
  enterShell = ''
    python --version
    uv --version
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;
}
