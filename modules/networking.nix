{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.networking =
    { pkgs, lib, ... }:
    {
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

      # There is a corresponding opensnitch client UI enabled in the HM section
      services.opensnitch = {
        enable = true;
        rules = {
          systemd-timesyncd = {
            name = "systemd-timesyncd";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
            };
          };
          nsncd = {
            name = "nsncd";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.nsncd}/bin/nsncd";
            };
          };
          zellij = {
            name = "zellij";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.zellij}/bin/zellij";
            };
          };
          zotero = {
            name = "zotero";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.zotero}/bin/zotero";
            };
          };
          crates-io = {
            name = "crates-io";
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
              type = "regexp";
              operand = "dest.host";
              data = "^(|.*\\.)crates\\.io$";
            };
          };
        };
      };

      # HM: opensnitch UI
      home-manager.users.${owner.username} = {
        services.opensnitch-ui.enable = true;
      };
    };
}
