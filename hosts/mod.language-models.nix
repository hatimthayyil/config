{ pkgs, ... }:
{
  services.ollama = {
    enable = false;
    package = pkgs.stable.ollama-cuda;

    # preload models, see https://ollama.com/library
    #loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b"];
  };

  services.open-webui = {
    # FIXME broken
    enable = false;
    port = 11500;
  };

  services.n8n = {
    enable = false;
  };

  services.qdrant = {
    enable = false;
    package = pkgs.stable.qdrant;
  };
}
