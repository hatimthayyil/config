{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.tools-secrets = _: {
    home-manager.users.${owner.username} = {
      programs = {
        gpg.enable = true;
        password-store.enable = true;
      };
    };
  };
}
