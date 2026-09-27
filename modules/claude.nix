{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
  claude-hatim = "/home/hatim/code/config/home/hatim/claude";
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
        let
          claudeLink = name: {
            source = config.lib.file.mkOutOfStoreSymlink "${claude-hatim}/${name}";
          };
        in
        {
          home.packages = [ llm-agents.claude-code ];

          home.file = {
            ".claude/settings.json" = claudeLink "settings.json";
            ".claude/CLAUDE.md" = claudeLink "CLAUDE.md";
          };
        };
    };
}
