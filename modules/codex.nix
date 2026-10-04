{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.codex =
    { pkgs, ... }:
    let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home-manager.users.${owner.username} =
        { config, ... }:
        {
          home = {
            packages = [ llm-agents.codex ];
            file.".codex".source =
              config.lib.file.mkOutOfStoreSymlink "/home/hatim/code/config/home/hatim/codex";
          };
        };
    };
}
