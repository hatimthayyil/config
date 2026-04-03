{
  config,
  inputs,
  ...
}:
{
  flake.modules.nixos.base = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      extraSpecialArgs = {
        inherit inputs;
        outputs = inputs.self;
      };

      users.${config.owner.username} = {
        imports = [
          inputs.nix-index-database.homeModules.nix-index
          inputs.emx.homeManagerModules.default
          inputs.nvf.homeManagerModules.default
          inputs.betterfox.modules.homeManager.betterfox
          (
            { osConfig, ... }:
            {
              home.stateVersion = osConfig.system.stateVersion;
              home.username = config.owner.username;
              home.homeDirectory = "/home/${config.owner.username}";
              programs.home-manager.enable = true;
              home.enableNixpkgsReleaseCheck = false;

              home.sessionPath = [
                "$HOME/.local/bin"
                "$HOME/.local/appimage/bin"
                "$HOME/.go/bin"
                "$HOME/.cargo/bin"
                "$HOME/.npm/bin"
                "$HOME/.opencode/bin"
              ];
            }
          )
        ];
      };
    };
  };
}
