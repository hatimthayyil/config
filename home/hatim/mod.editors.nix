{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Merge system-wide and home Info manuals top level directory.
  programs.info.enable = true;
  programs.emacs = {
    enable = false;
    package = pkgs.emacs-overlay.emacs-git-pgtk;
    extraPackages = (
      epkgs: [
        epkgs.treesit-grammars.with-all-grammars
      ]
    );
  };

  programs.emacs-emx = {
    enable = true;
    package = pkgs.emacs;
    #package = pkgs.emacs-overlay.emacs-git-pgtk;
    defaultEditor = true;
    treesitGrammars = [
      "all"
    ];
    localPath = "${config.home.homeDirectory}/src/emx";
  };

  programs.nvf = {
    enable = true;
    settings = {
      vim.viAlias = false;
      vim.vimAlias = true;
      vim.lsp = {
        enable = true;
      };
    };
  };

  home.file.".config/Code/User/settings.json".source = lib.mkForce (
    # TODO The current solution allows for the settings file to be writable and still be captured
    # in the repo tree. But the path is hardcoded. Implement a way to automatically get the path
    # of the file.
    config.lib.file.mkOutOfStoreSymlink "/home/hatim/src/config/home/hatim/file.vscode-settings.json"
  );

  # VScode using Nix4Vscode, to change the nixpkgs distribution, use with pkgs.vscode-extensions;  instead
  # of pkgs.nix4vscode.forVscode
  # TODO Split this off into an install in the profile and decouple it from Home
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

        # Development Tools
        "mhutchie.git-graph"
        #FIXME broken "eamodio.gitlens" # Git enhancements
        "vadimcn.vscode-lldb" # CodeLLDB
        "llvm-vs-code-extensions.lldb-dap" # DAP implementation from LLVM

        # Envrionment
        "mkhl.direnv"
        "ms-vscode-remote.remote-containers"

        # Themes
        "74th.monokai-charcoal-high-contrast"
        "gantoreno.vscode-vercel-theme"

        # Programming Languages
        "jnoortheen.nix-ide" # Nix
        "ms-python.python" # Python support
        "ms-toolsai.jupyter" # Jupyter Notebook support
        "marimo-team.vscode-marimo" # Jupyter alteranative
        "ms-vscode.cpptools" # C/C++ support
        #"rust-lang.rust-analyzer" # Rust support
        "golang.go" # Go support
        "redhat.java" # Java support
        "dart-code.dart-code" # Dart/Flutter support
        "svelte.svelte-vscode" # Svelte support
        "lencerf.beancount" # Beancount support
        "WolframResearch.wolfram"
        "mattn.lisp"
        "qingpeng.common-lisp" # Common Lisp support
        "betterthantomorrow.calva" # Clojure support
        "DioxusLabs.dioxus" # Dioxus Extension
        "myriad-dreamin.tinymist" # Typst

        # Web Development
        "dbaeumer.vscode-eslint" # Linting for JavaScript/TypeScript
        "ritwickdey.liveserver" # Live server for web development
        "bradlc.vscode-tailwindcss" # Tailwind CSS support
        "Selemondev.vscode-shadcn-svelte" # Shadcn Svelte
        "inlang.vs-code-extension" # inspector for i18n, translations, localization

        # DevOps and Cloud
        "ms-azuretools.vscode-docker" # Docker support
        "hashicorp.terraform" # Terraform support
        "redhat.ansible" # Ansible support
        "redhat.vscode-yaml" # YAML support

        # Productivity
        "fill-labs.dependi" # Dependency
        "esbenp.prettier-vscode" # Code formatter
        "johnpapa.vscode-peacock" # Change VSCode theme
        "shardulm94.trailing-spaces" # Highlight trailing spaces
        "tamasfe.even-better-toml" # TOML support
        # "alefragnani.bookmarks" # Code bookmarks
        "yzhang.markdown-all-in-one" # Markdown support
        "editorconfig.editorconfig" # EditorConfig support
        "gruntfuggly.todo-tree" # Highlight TODO comments
        "mechatroner.rainbow-csv" # Colored CSV files
        "tomoki1207.pdf" # Preview PDFs
      ];
    };
  };

  # Zed
  programs.zed-editor = {
    enable = true;
    package = pkgs.unstable.zed-editor;
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

  # Extra Editors
  programs.neovim.enable = false;
  programs.helix.enable = true;
  #LEAN programs.kakoune.enable = true;

  home.packages = [
    # Tools
    pkgs.lldb # LLVM debugger, needed for CodeLLDB extension in VSCode and LLDB DAP

    pkgs.texliveFull
    pkgs.texmacs
    pkgs.lyx
    pkgs.leo-editor
    pkgs.kibi # very lightweight editor

    #LEAN pkgs.windsurf # broken
    #LEAN pkgs.code-cursor
    #LEAN pkgs.vscodium-fhs

    # JetBrains IDEs
    #LEAN pkgs.stable.jetbrains.rust-rover
    #LEAN pkgs.stable.jetbrains.pycharm-community-bin
    #LEAN pkgs.stable.jetbrains.webstorm

    # Android
    #LEAN pkgs.android-studio

    # Smalltalk
    # pkgs.pharo
    # pkgs.squeak
    #LEAN pkgs.glamoroustoolkit
  ];
}
