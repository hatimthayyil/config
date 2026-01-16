{ pkgs, lib, ... }:
{
  programs.wireshark.enable = true;

  services.avahi = {
    enable = true;
    # Allows for .local mDNS resolution
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

  # There is correspnding openitch client UI that can be enabled in the
  # home-manager.
  services.opensnitch = {
    enable = true;
    rules = {
      # Programs
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

      # Hosts
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
}
