{ inputs, ... }:
{
  flake.modules.nixos.niks3-auto-upload =
    { config, pkgs, ... }:
    let
      cfg = config.services.niks3-auto-upload;
      niks3 = inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3;
      target = "/run/niks3-push-target";
    in
    {
      imports = [ inputs.niks3.nixosModules.niks3-auto-upload ];

      services.niks3-auto-upload = {
        enable = true;
        authTokenFile = config.sops.secrets."niks3-auth-token".path;
      };

      # The post-build-hook only fires on builds; paths substituted from a
      # remote builder reach the cache through this instead.
      system.activationScripts.niks3-push-system.text = ''
        printf '%s\n' "$systemConfig" > ${target}
        ${config.systemd.package}/bin/systemctl start --no-block niks3-push-system.service || true
      '';

      systemd = {
        services.niks3-push-system = {
          description = "Push the activated system closure to the binary cache";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "niks3-push-system" ''
              exec ${niks3}/bin/niks3 push \
                --server-url ${cfg.serverUrl} \
                --auth-token-path ${cfg.authTokenFile} \
                "$(< ${target})"
            '';
          };
        };

        timers.niks3-push-system = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
          };
        };
      };
    };
}
