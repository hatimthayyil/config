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

        home.packages = with llm-agents; [
          # Agents
          claude-code
          codex
          gemini-cli
          kimi-code
          opencode
          pi
          reasonix

          agent-browser # headless browser automation
          apm # agent package manager (Microsoft)
          beads # issue tracker
          codegraph # semantic code intelligence
          ctx # coding session search
          entire # link coding sessions to code changes
          herdr # terminal workspace manager
          jscpd # detect copy/paste duplication
          lean-ctx
          openspec
          plannotator # browser based interactive planner
          trellis # engineering framework
          workmux # Git worktree + tmux
          ralph-tui # Agent loop orchestrator
        ];
      };
    };
}
