# Home Manager module for the GitButler CLI, `but`.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gitbutler;
  jsonFormat = pkgs.formats.json { };
  settingsPath = "${config.xdg.configHome}/gitbutler/settings.json";
in
{
  options.programs.gitbutler = {
    enable = lib.mkEnableOption "the GitButler CLI";

    package = lib.mkPackageOption pkgs "but" { };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = {
        telemetry.appMetricsEnabled = false;
        fetch.autoFetchIntervalMinutes = -1;
      };
      description = ''
        Settings merged into {file}`$XDG_CONFIG_HOME/gitbutler/settings.json`
        on activation. `but` writes to that file itself, so it stays mutable:
        keys set here win, and other keys are kept.
      '';
    };

    skill = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "GitButler's agent skill, as installed by `but skill install` from {option}`package`.";
    };

    agentPolicy = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = ''
        GitButler's version-control instructions for agents, as printed by
        `but agent setup --print` from {option}`package`, without the setup markers.
      '';
    };
  };

  config = lib.mkMerge [
    {
      programs.gitbutler = {
        skill = pkgs.runCommand "gitbutler-skill" { nativeBuildInputs = [ cfg.package ]; } ''
          HOME=$TMPDIR but skill install --path $out
        '';

        agentPolicy =
          pkgs.runCommand "gitbutler-agent-policy.md" { nativeBuildInputs = [ cfg.package ]; }
            ''
              start='<!-- gitbutler-agent-setup:start -->'
              end='<!-- gitbutler-agent-setup:end -->'
              HOME=$TMPDIR but agent setup --print > policy.md
              grep -qxF "$start" policy.md
              grep -qxF "$end" policy.md
              grep -vxF -e "$start" -e "$end" policy.md > $out
            '';
      };
    }

    (lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];

      home.activation.gitbutlerSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings=${lib.escapeShellArg settingsPath}
        merged="$({ cat "$settings" 2>/dev/null || true; } \
          | ${lib.getExe pkgs.jq} -s --slurpfile new ${jsonFormat.generate "gitbutler-settings.json" cfg.settings} \
            '(.[0] // {}) * $new[0]')"
        if [[ -v DRY_RUN ]]; then
          verboseEcho "Would write $settings"
        else
          mkdir -p "$(dirname "$settings")"
          printf '%s\n' "$merged" > "$settings"
        fi
        unset settings merged
      '';
    })
  ];
}
