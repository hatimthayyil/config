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
      mkRule = action: name: type: operand: data: {
        inherit name action;
        enabled = true;
        duration = "always";
        operator = {
          inherit type operand data;
          sensitive = false;
        };
      };

      # Match any binary inside a nix-store package by name. Regex on
      # process.path so we survive store-hash churn and wrapper -> real-binary
      # exec (where /proc/PID/exe reports the inner binary, not the wrapper).
      allowPkg =
        pkgName: mkRule "allow" pkgName "regexp" "process.path" "^/nix/store/[a-z0-9]+-${pkgName}-[0-9].*$";
      allowExact = name: mkRule "allow" name "simple" "process.path";
      allowRegex = name: mkRule "allow" name "regexp" "process.path";
      allowDestHost = name: mkRule "allow" name "regexp" "dest.host";
      denyDestHost = name: mkRule "deny" name "regexp" "dest.host";

      home = "/home/${owner.username}";
    in
    {
      services.opensnitch = {
        enable = true;
        rules =
          lib.genAttrs [
            # ---------- System daemons ----------
            "avahi"
            "cups-browsed"
            "syncthing"
            "networkmanager"
            "fwupd"
            "geoclue"
            "discover"
            "speech-dispatcher"

            # ---------- Nix / shell tooling ----------
            "nix"
            "nh-unwrapped"
            "niks3-hook"
            "devenv"
            "mise"
            "curl"
            "openssh"
            "bind"
            "tealdeer"
            "suckit"

            # ---------- Git / forges ----------
            "git-with-svn"
            "gh"
            "lazygit"

            # ---------- Runtimes ----------
            "nodejs-slim"
            "bun"
            "electron-unwrapped"
            "bend"

            # ---------- Editors ----------
            "emacs"
            "zed-preview"
            "vscode"
            "cursor"

            # ---------- AI ----------
            "claude-desktop"
            "claude-code"
            "codex"
            "reasonix"
            "pi"
            "agentsview"
            "ccusage"
            "tokscale"
            "herdr"

            # ---------- Apps ----------
            "ungoogled-chromium-unwrapped"
            "firefox"
            "telegram-desktop"
            "discord-unwrapped"
            "nextcloud-client"
            "zotero"
            "flatpak"
            "wolfram-engine"
            "mathematica"
          ] allowPkg
          // {
            systemd-timesyncd = allowExact "systemd-timesyncd" "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
            nsncd = allowExact "nsncd" "${lib.getBin pkgs.nsncd}/bin/nsncd";
            zellij = allowExact "zellij" "${lib.getBin pkgs.zellij}/bin/zellij";

            zed-node-cache = allowRegex "zed-node-cache" "^${home}/\\.local/share/zed/node-cache/.*$";
            zed-extensions = allowRegex "zed-extensions" "^${home}/\\.local/share/zed/extensions/.*$";
            zed-external-agents = allowRegex "zed-external-agents" "^${home}/\\.local/share/zed/external_agents/.*$";
            claude-code-native = allowRegex "claude-code-native" "^${home}/\\.local/share/claude/versions/[^/]+$";
            claude-desktop-code = allowRegex "claude-desktop-code" "^${home}/\\.config/Claude/claude-code/[^/]+/claude$";

            crates-io = allowDestHost "crates-io" "^(|.*\\.)crates\\.io$";
            niks3 = allowDestHost "niks3" "^niks3\\.thayyil\\.workers\\.dev$";
            nixbuild = allowDestHost "nixbuild" "^eu\\.nixbuild\\.net$";

            datadog = denyDestHost "datadog" "^(|.*\\.)datadoghq\\.com$";
          };
      };

      home-manager.users.${owner.username} = {
        services.opensnitch-ui.enable = true;
      };
    };
}
