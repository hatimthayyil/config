_:
{
  flake.modules.nixos.guest-systems =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.kdePackages.krdc
      ];
    };
}
