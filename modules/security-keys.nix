# modules/security-keys.nix — smartcard/FIDO plumbing + key tooling.
_:
{
  flake.modules.nixos.security-keys =
    { pkgs, ... }:
    {
      services.pcscd.enable = true;
      services.udev.packages = [ pkgs.yubikey-personalization ];

      environment.systemPackages = [
        pkgs.yubikey-manager
        pkgs.age
        pkgs.age-plugin-yubikey
        pkgs.libfido2
      ];
    };
}
