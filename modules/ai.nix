{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.ai =
    { pkgs, ... }:
    let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      services.ollama = {
        enable = false;
        package = pkgs.stable.ollama-cuda;
      };

      services.open-webui = {
        enable = false;
        port = 11500;
      };

      services.n8n.enable = false;

      services.qdrant = {
        enable = false;
        package = pkgs.stable.qdrant;
      };

      home-manager.users.${owner.username} = {
        # Claude Code custom themes, selected in-app via /theme
        home.file = {
          ".claude/themes/modus-vivendi.json".source =
            "${inputs.claude-code-modus}/themes/modus-vivendi.json";
          ".claude/themes/modus-operandi.json".source =
            "${inputs.claude-code-modus}/themes/modus-operandi.json";
        };

        home.packages = [
          llm-agents.agent-browser
          llm-agents.beads
          llm-agents.claude-code
          llm-agents.codex
          llm-agents.gemini-cli
          llm-agents.opencode
          llm-agents.openspec
          llm-agents.pi
          llm-agents.reasonix
        ];
      };
    };
}
