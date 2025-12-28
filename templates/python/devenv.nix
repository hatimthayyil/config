{ pkgs, lib, config, inputs, ... }:

{
  packages = [
    pkgs.git
  ];

  languages.python = {
    enable = true;
    #version = "3.12.11";
    venv.enable = false;
    venv.requirements = ./requirements.txt;
  };

  git-hooks.hooks.pyright.enable = true;
}
