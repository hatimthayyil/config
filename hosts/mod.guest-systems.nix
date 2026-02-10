{
  pkgs,
  ...
}:
{
  # services.macos-ventura = {
  #   enable = false;
  #   openFirewall = true;
  #   vncListenAddr = "0.0.0.0";
  #   cores = 3;
  #   threads = 6;
  #   mem = "18G";
  #   autoStart = false;
  # };

  environment.systemPackages = [
    pkgs.kdePackages.krdc
  ];
}
