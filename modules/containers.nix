{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.containers =
    { pkgs, ... }:
    {
      # NixOS: container runtimes
      virtualisation.containers.enable = true;
      virtualisation.docker = {
        enable = true;
        rootless.enable = true;
        rootless.setSocketVariable = true;

        daemon.settings = {
          userland-proxy = false;
          experimental = true;
          fixed-cidr-v6 = "fd00::/80";
          ipv6 = true;
          live-restore = true;
        };
      };

      virtualisation.podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      environment.systemPackages = with pkgs; [
        dive
        podman-tui
        docker-compose
        podman-compose
      ];

      # HM: user-level container tools
      home-manager.users.${owner.username} = {
        programs.distrobox.enable = true;
      };
    };
}
