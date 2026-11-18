_: {
  flake.modules.nixos.networking = _: {
    networking.extraHosts = ''
      127.0.0.1 chat.local
      127.0.0.1 cloud.local
    '';

    services.nginx = {
      enable = false;

      virtualHosts."chat.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:11500";
          proxyWebsockets = true;
        };
      };
    };

    programs.wireshark.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      settings = {
        publish = {
          disable-publishing = false;
          disable-user-service-publishing = false;
          publish-addresses = true;
          publish-domain = true;
          publish-hinfo = true;
          publish-workstation = true;
        };
      };
    };
  };
}
