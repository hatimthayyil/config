{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.version-control =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} =
        { config, ... }:
        {
          programs.git = {
            enable = true;
            package = pkgs.gitFull;

            settings.user = {
              email = "hatim@thayyil.net";
              name = "Hatim Thayyil";
              signingKey = "~/.ssh/id_ed25519_sk_sign.pub";
            };

            lfs.enable = true;

            ignores = [
              "*.drv"
              "result"
              ".direnv"
              ".codegraph"
            ];

            settings = {
              log.showSignature = true;
              init.defaultBranch = "main";
              pull.rebase = false;

              # SSH commit signing (touch-to-sign).
              gpg.format = "ssh";
              gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
              commit.gpgSign = true;
              tag.gpgSign = true;
            };

            settings.alias = {
              st = "status";
              ld = "log --patch --ext-diff";
              co = "checkout";
              ad = "add";
              ap = "add -p";
              dt = "diff";
              di = "diff --cached";
              ci = "commit";
              rt = "restore";
              ri = "restore --staged";
              pl = "pull";
              br = "branch";
              sw = "!git branch | fzf | xargs git switch";
              cp = "cherry-pick";
              pick = "!git log --online | fzf | cut -d' ' -f1 | xargs git cherry-pick";
            };
          };

          programs.git-worktree-switcher.enable = true;

          programs.difftastic = {
            enable = true;
            git.enable = true;
          };

          programs.jujutsu = {
            enable = true;
            settings = {
              user = {
                inherit (config.programs.git.settings.user) name;
                inherit (config.programs.git.settings.user) email;
              };
              ui = {
                show-cryptographic-signatures = true;
                diff.tool = [
                  "difft"
                  "--color=always"
                  "$left"
                  "$right"
                ];
              };
            };
          };

          programs.mercurial = {
            enable = true;
            userName = config.programs.git.settings.user.name;
            userEmail = config.programs.git.settings.user.email;
          };

          programs.lazygit = {
            enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = true;
          };
          programs.gitui.enable = true;

          # allowed-signers: committer email -> signing key, for local verify.
          # One line per signing key.
          home.file.".ssh/allowed_signers".text =
            "hatim@thayyil.net sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKs8D0fSrd6GkEHtQI0UOiP2QtdNNmzJ732UrS4XEM33AAAADnNzaDplYWdsZS1zaWdu\n";

          home.packages = [
            pkgs.tig
            pkgs.cvs
            pkgs.mr
            pkgs.hut
            # pkgs.commitlint
            # pkgs.commitizen
            pkgs.git-machete
            pkgs.git-imerge
            pkgs.git-annex
            pkgs.git-absorb
            pkgs.git-ignore
          ];
        };
    };
}
