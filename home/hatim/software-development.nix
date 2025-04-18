{
  pkgs,
  ...
}: {
  programs = {
    direnv.enable = true;
    jq.enable = true; # JSON processor
  };
  home.packages = [
    # Dev
    pkgs.gnumake
    pkgs.just
    pkgs.curl
    pkgs.curlie # frontend for curl
    pkgs.shellcheck
  ];
}
