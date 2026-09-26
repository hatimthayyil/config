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

      home-manager.users.${owner.username} =
        { config, ... }:
        {
          home.packages =
            with llm-agents;
            [
              # Agents
              claude-code
              codex
              dsh
              gemini-cli
              kimi-code
              opencode
              reasonix
              zcode

              agent-browser # headless browser automation
              apm # agent package manager (Microsoft)
              ax # fetch, discover, extract web content
              beads # issue tracker
              but # GitButler CLI: stacked and parallel branches
              codegraph # semantic code intelligence
              ctx # coding session search
              git-ai # line-level AI attribution in Git Notes
              gitbutler # GitButler GUI
              herdr # terminal workspace manager
              hunk # diff with review
              jscpd # detect copy/paste duplication
              lean-ctx
              mindwalk
              openspec
              plannotator # browser based interactive planner
              tokscale
              trellis # engineering framework
              workmux # Git worktree + tmux
              ralph-tui # Agent loop orchestrator
            ]
            ++ [
              pkgs.claude-desktop-fhs
            ];

          # See agents/comments/modules/ai.nix.md.
          programs.git.settings.trace2 = {
            eventTarget = "af_unix:stream:${config.home.homeDirectory}/.git-ai/internal/daemon/trace2.sock";
            eventNesting = "0";
          };

          home.file.".config/herdr/config.toml".source =
            config.lib.file.mkOutOfStoreSymlink "/home/hatim/code/config/home/hatim/file.herdr-config.toml";
        };
    };
}
