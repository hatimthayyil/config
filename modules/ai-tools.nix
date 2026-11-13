{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.ai-tools = {
    home-manager.users.${owner.username} = {
      imports = [ inputs.ai-tools.homeModules.default ];

      services.ai-tools.backup.enable = true;
    };
  };
}
