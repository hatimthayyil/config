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
      environment.etc."claude-code/managed-settings.json".text = builtins.toJSON {
        extraKnownMarketplaces.ai.source = {
          source = "directory";
          path = "/home/hatim/.nix-profile/share/ai/plugins";
        };
        enabledPlugins."ai@ai" = true;
        appendPlugins = [ "ai@ai" ];
      };

      home-manager.users.${owner.username} =
        { config, ... }:
        {
          home = {
            packages = [
              llm-agents.claude-code
              pkgs.clauth
            ];
            sessionVariables = {
              CLAUTH_NO_UPDATE = "1";
              CLAUDE_CODE_AUTO_CONNECT_IDE = "false";
            };
            file.".claude".source =
              config.lib.file.mkOutOfStoreSymlink "/home/hatim/code/config/home/hatim/claude";
          };
        };
    };
}
