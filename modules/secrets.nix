{ inputs, ... }:
{
  flake.modules.nixos.secrets =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops.age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      sops.defaultSopsFile = ../hosts/eagle/secrets.yaml;

      environment.systemPackages = [ pkgs.sops ];
    };
}
