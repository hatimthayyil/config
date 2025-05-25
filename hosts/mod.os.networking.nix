{ ... }:
{
  programs.wireshark.enable = true;

  # There is correspnding openitch client UI that can be enabled in the
  # home-manager.
  services.opensnitch = {
    enable = true;
  };
}
