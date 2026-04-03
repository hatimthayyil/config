{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.language-machine =
    { pkgs, ... }:
    {
      # NixOS: language model services
      services.ollama = {
        enable = false;
        package = pkgs.stable.ollama-cuda;
      };

      services.open-webui = {
        enable = false;
        port = 11500;
      };

      services.n8n.enable = false;

      services.qdrant = {
        enable = false;
        package = pkgs.stable.qdrant;
      };

      # HM: GPU tools and language model clients
      home-manager.users.${owner.username} = {
        home.packages = [
          # GPU
          pkgs.mesa-demos
          pkgs.vulkan-tools
          pkgs.libva-utils
          pkgs.clinfo
          pkgs.lact
        ];
      };
    };
}
