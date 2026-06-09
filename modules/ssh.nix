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
        };
      };

      # Dedicated ssh-agent (replaces gpg-agent's SSH role).
      services.ssh-agent.enable = true;
    };
  };
}
