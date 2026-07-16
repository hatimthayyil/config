{ inputs, ... }:
{
  flake.modules.nixos.secrets =
    { pkgs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        defaultSopsFile = ../hosts/eagle/secrets.yaml;
        secrets."niks3-auth-token" = { };
      };

      environment.systemPackages = [ pkgs.sops ];
    };
}
