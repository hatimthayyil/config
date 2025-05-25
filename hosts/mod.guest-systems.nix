{ pkgs,
  ...
}: {
  services.macos-ventura = {
    enable = true;
    openFirewall = true;
    vncListenAddr = "0.0.0.0";
  };

  environment.systemPackages = [
    pkgs.kdePackages.krdc
  ];
}
