{ config, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.nix = {
    home-manager.users.${owner.username} =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        tokens = "${config.xdg.configHome}/nix/access-tokens.conf";
      in
      {
        # GitHub's API rate-limits anonymous flake fetches. The token comes
        # from gh's keyring at login, so it stays out of the store and follows
        # `gh auth login`. `!include` skips the file while it is missing.
        nix.extraOptions = ''
          !include ${tokens}
        '';

        systemd.user.services.nix-github-token = {
          Unit = {
            Description = "Give Nix the GitHub token from gh";
            After = [ "graphical-session.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = lib.getExe (
              pkgs.writeShellApplication {
                name = "nix-github-token";
                runtimeInputs = [
                  pkgs.coreutils
                  pkgs.gh
                ];
                text = ''
                  umask 077
                  token=$(gh auth token)
                  tmp=$(mktemp "${tokens}.XXXXXX")
                  trap 'rm -f "$tmp"' EXIT
                  printf 'access-tokens = github.com=%s\n' "$token" >"$tmp"
                  mv "$tmp" "${tokens}"
                '';
              }
            );
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
  };
}
