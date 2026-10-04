{ config, ... }:
let
  inherit (config) owner;
  agentsDir = "/home/hatim/code/config/home/hatim/agents";
in
{
  flake.modules.nixos.agent-skills = {
    home-manager.users.${owner.username} =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        inherit (pkgs.agent-skills) github;

        manifest = {
          bd-to-br-migration = github.dicklesworthstone.beads_rust.bd-to-br-migration;
          find-skills = github.vercel-labs.skills.find-skills;
          rust-skills = pkgs.fetchFromGitHub {
            owner = "curtisault";
            repo = "rust-skills";
            rev = "a04921b2d85583aea9ec7441a66ab878ca694b9a";
            hash = "sha256-vT95wGYeHSHNiRjcsdRMT8q5hxD8b3DK3cV0OZxWXz8=";
          };
          stop-slop = github.hardikpandya.stop-slop.stop-slop;
        };

        sync = pkgs.writeShellApplication {
          name = "agent-skills-sync";
          runtimeInputs = with pkgs; [
            coreutils
            gawk
            git
          ];
          text = builtins.readFile ./agent-skills-sync.sh;
        };
      in
      {
        home = {
          file.".agents".source = config.lib.file.mkOutOfStoreSymlink agentsDir;
          activation.agentSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            run ${lib.getExe sync} ${pkgs.linkFarm "agent-skills" manifest} ${lib.escapeShellArg "${agentsDir}/skills"}
          '';
        };
      };
  };
}
