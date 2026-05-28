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
        matchBlocks = {
          "ssh.lightning.ai" = {
            identityFile = "~/.ssh/lightning_rsa";
            identitiesOnly = true;
            serverAliveInterval = 15;
            serverAliveCountMax = 4;
            extraOptions = {
              StrictHostKeyChecking = "no";
              UserKnownHostsFile = "/dev/null";
            };
          };
        };
      };
    };
  };
}
