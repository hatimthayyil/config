{
  pkgs,
  ...
}: {
  home.packages = [
    # Astronomy
    pkgs.stellarium
    pkgs.celestia
    pkgs.gpredict
  ];
}
