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
          find-skills = github.vercel-labs.skills.find-skills;
          stop-slop = github.hardikpandya.stop-slop.stop-slop;
        }
        // lib.optionalAttrs config.programs.gitbutler.enable {
          but = config.programs.gitbutler.skill;
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
