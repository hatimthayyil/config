{ pkgs, ... }:

{
  packages = [ pkgs.git ];

  languages.javascript = {
    enable = true;
    npm.enable = true;
  };
}
