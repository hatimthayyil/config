{
  pkgs,
  ...
}: {
  virtualisation.containers.enable = true;
  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
    rootless.setSocketVariable = true;

    daemon.settings = {
      userland-proxy = false; # For Windows
      experimental = true;
      fixed-cidr-v6 = "fd00::/80";
      ipv6 = true;
      live-restore = true;
    };
  };

  virtualisation.podman = {
    enable = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

  # Useful other development tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
    podman-compose # start group of containers for dev
  ];
}
