# GitButler CLI through the local `programs.gitbutler` Home Manager module.
{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.version-control =
    { pkgs, ... }:
    let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home-manager.sharedModules = [ ./_gitbutler-hm-module.nix ];

      home-manager.users.${owner.username} = {
        programs.gitbutler = {
          enable = true;
          package = llm-agents.but;
          settings = {
            telemetry = {
              appMetricsEnabled = false;
              appErrorReportingEnabled = false;
            };
            fetch.autoFetchIntervalMinutes = -1;
            agentSkillNotices = false;
          };
        };
      };
    };
}
