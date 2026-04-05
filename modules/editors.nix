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
            settings.vim = {
              viAlias = false;
              vimAlias = true;
              searchCase = "smart";
              undoFile.enable = true;

              theme = {
                enable = true;
                name = "tokyonight";
                style = "night";
              };

              lsp = {
                enable = true;
                formatOnSave = true;
                inlayHints.enable = true;
                trouble.enable = true;
                lspkind.enable = true;
                lightbulb.enable = true;
                mappings = {
                  goToDefinition = "gd";
                  goToDeclaration = "gD";
                  goToType = "gy";
                  listImplementations = "gi";
                  listReferences = "gr";
                  hover = "K";
                  renameSymbol = "<leader>r";
                  codeAction = "<leader>a";
                  nextDiagnostic = "]d";
                  previousDiagnostic = "[d";
                };
              };

              languages = {
                enableFormat = true;
                enableTreesitter = true;
                enableExtraDiagnostics = true;
                nix.enable = true;
                lua.enable = true;
                bash.enable = true;
                python.enable = true;
                go.enable = true;
                rust.enable = true;
                ts.enable = true;
                html.enable = true;
                css.enable = true;
                svelte.enable = true;
                tailwind.enable = true;
                markdown.enable = true;
                json.enable = true;
                toml.enable = true;
                yaml.enable = true;
                sql.enable = true;
                typst.enable = true;
              };

              autocomplete.blink-cmp = {
                enable = true;
                friendly-snippets.enable = true;
                setupOpts = {
                  completion.documentation.auto_show = true;
                  fuzzy = {
                    implementation = "prefer_rust";
                    prebuilt_binaries.download = false;
                  };
                };
              };

              snippets.luasnip.enable = true;
              treesitter.context.enable = true;

              fzf-lua = {
                enable = true;
                profile = "fzf-native";
              };

              statusline.lualine.enable = true;
              filetree.neo-tree.enable = true;
              git.gitsigns.enable = true;

              terminal.toggleterm = {
                enable = true;
                lazygit.enable = true;
              };

              binds.whichKey = {
                enable = true;
                setupOpts.preset = "helix";
              };
              autopairs.nvim-autopairs.enable = true;
              comments.comment-nvim.enable = true;
              utility.surround.enable = true;

              visuals = {
                nvim-web-devicons.enable = true;
                indent-blankline.enable = true;
              };

              ui.borders.enable = true;

              clipboard = {
                enable = true;
                registers = "unnamedplus";
                providers.wl-copy.enable = true;
              };

              extraPlugins.vim-tmux-navigator = {
                package = pkgs.vimPlugins.vim-tmux-navigator;
              };

              options = {
                signcolumn = "yes";
                cursorline = true;
                scrolloff = 8;
                wrap = false;
                splitright = true;
                splitbelow = true;
                shiftwidth = 2;
                tabstop = 2;
              };

              # Helix-style space menu
              keymaps = [
                {
                  mode = "n";
                  key = "<leader>f";
                  action = "<cmd>FzfLua files<CR>";
                  desc = "Find files";
                }
                {
                  mode = "n";
                  key = "<leader>/";
                  action = "<cmd>FzfLua live_grep<CR>";
                  desc = "Live grep";
                }
                {
                  mode = "n";
                  key = "<leader>b";
                  action = "<cmd>FzfLua buffers<CR>";
                  desc = "Buffers";
                }
                {
                  mode = "n";
                  key = "<leader>g";
                  action = "<cmd>FzfLua git_status<CR>";
                  desc = "Git status";
                }
                {
                  mode = "n";
                  key = "<leader>s";
                  action = "<cmd>FzfLua lsp_document_symbols<CR>";
                  desc = "Document symbols";
                }
                {
                  mode = "n";
                  key = "<leader>S";
                  action = "<cmd>FzfLua lsp_workspace_symbols<CR>";
                  desc = "Workspace symbols";
                }
                {
                  mode = "n";
                  key = "<leader>d";
                  action = "<cmd>FzfLua diagnostics_document<CR>";
                  desc = "Document diagnostics";
                }
                {
                  mode = "n";
                  key = "<leader>D";
                  action = "<cmd>FzfLua diagnostics_workspace<CR>";
                  desc = "Workspace diagnostics";
                }
                {
                  mode = "n";
                  key = "<leader>'";
                  action = "<cmd>FzfLua resume<CR>";
                  desc = "Resume last picker";
                }
                {
                  mode = "n";
                  key = "<leader>?";
                  action = "<cmd>FzfLua commands<CR>";
                  desc = "Command palette";
                }
                {
                  mode = "n";
                  key = "<leader>j";
                  action = "<cmd>FzfLua jumps<CR>";
                  desc = "Jumplist";
                }
              ];
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
            settings = {
              theme = "tokyonight";
              editor = {
                line-number = "relative";
                cursorline = true;
                scrolloff = 8;
                color-modes = true;
                auto-format = true;
                popup-border = "all";
                bufferline = "multiple";
                end-of-line-diagnostics = "hint";
                cursor-shape = {
                  normal = "block";
                  insert = "bar";
                  select = "underline";
                };
                lsp.display-inlay-hints = true;
                auto-save.focus-lost = true;
                soft-wrap.enable = true;
                inline-diagnostics = {
                  cursor-line = "warning";
                  other-lines = "disable";
                };
              };
            };
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
