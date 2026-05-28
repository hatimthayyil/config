_: {
  flake.modules.nixos.networking = _: {
    networking.extraHosts = ''
      127.0.0.1 chat.local
      127.0.0.1 ollama.local
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

      virtualHosts."ollama.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:11434";
        };
      };
    };

    programs.wireshark.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };
  };
}
