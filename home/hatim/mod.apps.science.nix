{
  pkgs,
  ...
}:
{
  home.packages = [
    # Astronomy
    pkgs.stable.stellarium
    pkgs.stable.celestia
    pkgs.stable.gpredict
  ];
}
