{ inputs, ... }:
{
  flake.modules.nixos.secrets =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      sops.defaultSopsFile = ../hosts/eagle/secrets.yaml;

      environment.systemPackages = [ pkgs.sops ];
    };
}
