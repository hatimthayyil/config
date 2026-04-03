{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.editors =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} =
        { config, lib, ... }:
        {
          programs.info.enable = true;
          programs.emacs = {
            enable = false;
            package = pkgs.emacs-overlay.emacs-git-pgtk;
            extraPackages = epkgs: [
              epkgs.treesit-grammars.with-all-grammars
            ];
          };

          programs.emacs-emx = {
            enable = true;
            package = pkgs.emacs;
            defaultEditor = false;
            treesitGrammars = [ "all" ];
            localPath = "${config.home.homeDirectory}/src/emx";
          };

          programs.nvf = {
            enable = true;
            settings = {
              vim.viAlias = false;
              vim.vimAlias = true;
              vim.lsp.enable = true;
            };
          };

          home.file.".config/Code/User/settings.json".source = lib.mkForce (
            config.lib.file.mkOutOfStoreSymlink "/home/hatim/code/config/home/hatim/file.vscode-settings.json"
          );

          programs.vscode = {
            enable = true;
            package = pkgs.unstable.vscode;
            profiles.default = {
              extensions = pkgs.nix4vscode.forVscodeVersion "1.108.1" [
                "github.copilot"
                "github.copilot-chat"
                "sst-dev.opencode-v2"
                "anthropic.claude-code"
                "openai.chatgpt"
                "google.colab"
                "planet57.vscode-beads"

                # Development Tools
                "mhutchie.git-graph"
                "vadimcn.vscode-lldb"
                "llvm-vs-code-extensions.lldb-dap"
                "vivaxy.vscode-conventional-commits"

                # Environment
                "mkhl.direnv"
                "ms-vscode-remote.remote-containers"

                # Themes
                "74th.monokai-charcoal-high-contrast"
                "gantoreno.vscode-vercel-theme"

                # Programming Languages
                "jnoortheen.nix-ide"
                "ms-python.python"
                "ms-toolsai.jupyter"
                "marimo-team.vscode-marimo"
                "ms-vscode.cpptools"
                "golang.go"
                "redhat.java"
                "dart-code.dart-code"
                "svelte.svelte-vscode"
                "lencerf.beancount"
                "WolframResearch.wolfram"
                "mattn.lisp"
                "qingpeng.common-lisp"
                "betterthantomorrow.calva"
                "DioxusLabs.dioxus"
                "myriad-dreamin.tinymist"

                # Web Development
                "dbaeumer.vscode-eslint"
                "ritwickdey.liveserver"
                "bradlc.vscode-tailwindcss"
                "Selemondev.vscode-shadcn-svelte"
                "inlang.vs-code-extension"

                # DevOps and Cloud
                "ms-azuretools.vscode-docker"
                "hashicorp.terraform"
                "redhat.ansible"
                "redhat.vscode-yaml"

                # Productivity
                "fill-labs.dependi"
                "esbenp.prettier-vscode"
                "johnpapa.vscode-peacock"
                "shardulm94.trailing-spaces"
                "tamasfe.even-better-toml"
                "yzhang.markdown-all-in-one"
                "editorconfig.editorconfig"
                "gruntfuggly.todo-tree"
                "mechatroner.rainbow-csv"
                "tomoki1207.pdf"
              ];
            };
          };

          programs.zed-editor = {
            enable = true;
            package = pkgs.unstable.zed-editor-fhs;
            extensions = [
              "codebook"

              # Language Servers
              "make"
              "just"
              "helm"
              "beancount"
              "dockerfile"
              "docker-compose"
              "nix"
              "sql"
              "toml"
              "typst"
              "html"
              "svelte"
              "latex"
              "racket"

              # Snippets
              "html-snippets"

              # Agent Servers
              "opencode"

              # MCPs
              "mcp-server-context7"
              "mcp-server-puppeteer"
              "mcp-server-github"
              "mcp-server-gitlab"
              "mcp-server-sequential-thinking"
              "serena-context-server"
              "postgres-context-server"
              "chrome-devtools-mcp"
              "svelte-mcp"
              "mcp-server-figma"
              "shadcn-mcp"
              "arch-mcp"
              "mcp-server-repomix"

              # Themes
              "catppuccin"
              "vercel-theme"
              "v0-theme"
              "dogi"
              "the-dark-side"
              "modus-themes"
              "monokai-pro-ce"
              "vscode-monokai-charcoal"
            ];
            extraPackages = [
              pkgs.repomix
              pkgs.nil
              pkgs.mcp-nixos
            ];
            userSettings = {
              context_servers = {
                nixos = {
                  command = "nix";
                  args = [
                    "run"
                    "github:utensils/mcp-nixos"
                    "--"
                  ];
                };
              };
            };
          };

          programs.neovim.enable = false;
          programs.helix = {
            enable = true;
            defaultEditor = true;
          };

          home.packages = [
            pkgs.lldb
            pkgs.texliveFull
            pkgs.texmacs
            pkgs.lyx
            pkgs.leo-editor
            pkgs.kibi
          ];
        };
    };
}
