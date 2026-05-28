{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.opensnitch =
    { pkgs, lib, ... }:
    let
      # Match any binary inside a nix-store package by name. Regex on
      # process.path so we survive store-hash churn and wrapper -> real-binary
      # exec (where /proc/PID/exe reports the inner binary, not the wrapper).
      allowPkg = pkgName: {
        name = pkgName;
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.path";
          data = "^/nix/store/[a-z0-9]+-${pkgName}-.*$";
        };
      };

      allowExact = name: path: {
        inherit name;
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          sensitive = false;
          operand = "process.path";
          data = path;
        };
      };

      allowRegex = name: regex: {
        inherit name;
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.path";
          data = regex;
        };
      };

      allowDestHost = name: hostRegex: {
        inherit name;
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          operand = "dest.host";
          data = hostRegex;
        };
      };

      home = "/home/${owner.username}";
    in
    {
      services.opensnitch = {
        enable = true;
        rules = {
          # ---------- System daemons ----------
          systemd-timesyncd = allowExact "systemd-timesyncd" "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
          nsncd = allowExact "nsncd" "${lib.getBin pkgs.nsncd}/bin/nsncd";
          avahi = allowPkg "avahi";
          cups-browsed = allowPkg "cups-browsed";
          syncthing = allowPkg "syncthing";

          # ---------- Shell / tooling ----------
          zellij = allowExact "zellij" "${lib.getBin pkgs.zellij}/bin/zellij";
          nh = allowPkg "nh-unwrapped";

          # ---------- Git / forges ----------
          git = allowPkg "git-with-svn";
          gh = allowPkg "gh";

          # ---------- Editors ----------
          emacs = allowPkg "emacs-git-pgtk";
          zed-editor = allowRegex "zed-editor" "^${home}/\\.local/zed\\.dev/.*/zed-editor$";
          zed-node-cache = allowRegex "zed-node-cache" "^${home}/\\.local/share/zed/node-cache/.*$";
          zed-extensions = allowRegex "zed-extensions" "^${home}/\\.local/share/zed/extensions/.*$";

          # ---------- Apps ----------
          ungoogled-chromium = allowPkg "ungoogled-chromium-unwrapped";
          telegram-desktop = allowPkg "telegram-desktop";
          claude-desktop = allowPkg "claude-desktop";
          claude-cli = allowRegex "claude-cli" "^${home}/\\.local/share/claude/versions/[^/]+/claude$";
          nextcloud-client = allowPkg "nextcloud-client";
          zotero = allowPkg "zotero";

          # ---------- Destinations ----------
          crates-io = allowDestHost "crates-io" "^(|.*\\.)crates\\.io$";
        };
      };

      home-manager.users.${owner.username} = {
        services.opensnitch-ui.enable = true;
      };
    };
}
