{
  pkgs,
  ...
}: {
  home.packages = [
    # Astronomy
    pkgs.stable.stellarium
    pkgs.celestia
    pkgs.gpredict
  ];
}
