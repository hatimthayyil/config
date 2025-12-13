# Development environment for Python with uv
#
# See full reference at https://devenv.sh/reference/options/

{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  packages = with pkgs; [
    zlib
  ];

  languages.python = {
    enable = true;
    uv.enable = true;
  };

  # https://devenv.sh/basics/
  enterShell = ''
    python --version
    uv --version
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;
}
