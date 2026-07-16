{ inputs, ... }:
{
  flake.modules.nixos.niks3-auto-upload =
    { config, ... }:
    {
      imports = [ inputs.niks3.nixosModules.niks3-auto-upload ];

      services.niks3-auto-upload = {
        enable = true;
        serverUrl = "https://niks3.thayyil.workers.dev";
        authTokenFile = config.sops.secrets."niks3-auth-token".path;
      };
    };
}
