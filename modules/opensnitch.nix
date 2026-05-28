{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.opensnitch =
    { pkgs, lib, ... }:
    {
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

      home-manager.users.${owner.username} = {
        services.opensnitch-ui.enable = true;
      };
    };
}
