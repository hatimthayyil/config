{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.ssh = {
    home-manager.users.${owner.username} = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "*" = {
            ForwardAgent = false;
            AddKeysToAgent = "yes";
            IdentityFile = "~/.ssh/id_ed25519_sk";
            Compression = false;
            ServerAliveInterval = 0;
            ServerAliveCountMax = 3;
            HashKnownHosts = false;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = "no";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = "no";
          };
          "ssh.lightning.ai" = {
            IdentityFile = "~/.ssh/lightning_rsa";
            IdentitiesOnly = true;
            ServerAliveInterval = 15;
            ServerAliveCountMax = 4;
            StrictHostKeyChecking = "no";
            UserKnownHostsFile = "/dev/null";
          };
          "eu.nixbuild.net" = {
            IdentityFile = "/etc/ssh/ssh_host_ed25519_key";
            PubkeyAcceptedKeyTypes = "ssh-ed25519";
            ServerAliveInterval = 60;
          };
        };
      };

      # Dedicated ssh-agent (replaces gpg-agent's SSH role).
      services.ssh-agent.enable = true;
    };

    programs.ssh = {
      extraConfig = ''
        Host eu.nixbuild.net
          PubkeyAcceptedKeyTypes ssh-ed25519
          ServerAliveInterval 60
          IdentityFile /etc/ssh/ssh_host_ed25519_key
      '';

      knownHosts.nixbuild = {
        hostNames = [ "eu.nixbuild.net" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };
  };
}
