{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hatim.modules.editors;
in
{
  options.hatim.modules.editors = {
    enable = lib.mkEnableOption "editor configurations";
    emacs.enable = lib.mkEnableOption "Emacs editor" // {
      default = true;
    };
    neovim.enable = lib.mkEnableOption "Neovim editor" // {
      default = true;
    };
    vscode.enable = lib.mkEnableOption "VSCode editor" // {
      default = true;
    };
    zedEditor.enable = lib.mkEnableOption "Zed editor" // {
      default = true;
    };
    helix.enable = lib.mkEnableOption "Helix editor" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # Info pages
    programs.info.enable = true;

    # Emacs (using EMX distribution)
    programs.emacs-emx = lib.mkIf cfg.emacs.enable {
      enable = true;
      package = pkgs.emacs;
      defaultEditor = true;
      treesitGrammars = [ "all" ];
      localPath = "${config.home.homeDirectory}/src/emx";
    };

    # Neovim (using nvf)
    programs.nvf = lib.mkIf cfg.neovim.enable {
      enable = true;
      settings = {
        vim.viAlias = false;
        vim.vimAlias = true;
        vim.lsp = {
          enable = true;
        };
      };
    };

    # VSCode
    programs.vscode = lib.mkIf cfg.vscode.enable {
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

    # VSCode settings file symlink
    home.file.".config/Code/User/settings.json".source = lib.mkForce (
      config.lib.file.mkOutOfStoreSymlink "/home/hatim/code/config/home/hatim/file.vscode-settings.json"
    );

    # Zed Editor
    programs.zed-editor = lib.mkIf cfg.zedEditor.enable {
      enable = true;
      package = pkgs.unstable.zed-editor;
      extensions = [
        "codebook"
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
        "html-snippets"
        "opencode"
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

    # Helix
    programs.helix = lib.mkIf cfg.helix.enable {
      enable = true;
    };

    # Additional packages
    home.packages = [
      pkgs.lldb
      pkgs.texliveFull
      pkgs.texmacs
      pkgs.lyx
      pkgs.leo-editor
      pkgs.kibi
    ];
  };
}
