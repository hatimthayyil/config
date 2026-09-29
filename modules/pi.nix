{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
  pi-hatim = "/home/hatim/code/config/home/hatim/pi";
in
{
  flake.modules.nixos.pi =
    { pkgs, ... }:
    let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home-manager.users.${owner.username} =
        { config, ... }:
        {
          programs.pi-coding-agent = {
            enable = true;
            package = llm-agents.pi;
            extraPackages = [ pkgs.nodejs ];
          };

          home.file = {
            ".pi/agent" = {
              source = config.lib.file.mkOutOfStoreSymlink pi-hatim;
            };
          };
        };
    };
}
