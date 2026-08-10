{ config, inputs, ... }:
let
  inherit (config) owner;

  extensions = [
    "github.copilot"
    "github.copilot-chat"
    "sst-dev.opencode-v2"
    # "anthropic.claude-code"
    # "openai.chatgpt"
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
    # "marimo-team.vscode-marimo"
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
    "rust-lang.rust-analyzer"

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
in
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ config.flake.overlays.default ];
      };
      editor = pkgs.unstable.vscode;
    in
    {
      packages.vscode-extensions = pkgs.buildEnv {
        name = "vscode-extensions";
        paths = pkgs.nix4vscode.forVscodeVersion editor.version extensions;
      };
    };

  flake.modules.nixos.vscode =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} =
        { config, lib, ... }:
        {
          home.file.".config/Code/User/settings.json".source = lib.mkForce (
            config.lib.file.mkOutOfStoreSymlink "/home/hatim/code/config/home/hatim/file.vscode-settings.json"
          );

          programs.vscode = {
            enable = true;
            package = pkgs.unstable.vscode;
          };
        };
    };
}
