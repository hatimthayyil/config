{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.claude =
    { pkgs, ... }:
    let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home-manager.users.${owner.username} =
        { config, ... }:
        {
          home = {
            packages = [ llm-agents.claude-code ];
            file.".claude".source =
              config.lib.file.mkOutOfStoreSymlink "/home/hatim/code/config/home/hatim/claude";
          };
        };
    };
}
