{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.cli-utils =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        programs = {
          btop.enable = true;
          bat.enable = true;
          fastfetch.enable = true;
          tealdeer.enable = true;

          fd.enable = true;
          fzf = {
            enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = true;
            tmux.enableShellIntegration = true; # needed for sesh
          };
          ripgrep = {
            enable = true;
            arguments = [
              "--max-columns-preview"
              "--colors=line:style:bold"
              "--smart-case"
            ];
          };
          ripgrep-all.enable = true;
          skim = {
            enable = true;
            enableBashIntegration = true;
          };

          zoxide = {
            enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = true;
          };
          sesh = {
            enable = true;
            enableAlias = false; # default alias uses $(…) which is invalid nushell syntax
          };
          zellij = {
            enable = true;
            settings.copy_command = "wl-copy";
          };

          lsd = {
            enable = true;
            enableBashIntegration = true;
          };
          yazi = {
            enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = true;
            shellWrapperName = "y";
          };
          broot = {
            enable = false;
            enableBashIntegration = true;
            enableNushellIntegration = true;
          };

          television = {
            enable = true;
            enableBashIntegration = true;
            enableNushellIntegration = true;
            enableFishIntegration = true;
          };

          nix-search-tv = {
            enable = true;
            settings.indexes = [
              "nixpkgs"
              "home-manager"
              "nixos"
            ];
          };
        };

        home.packages = [
          pkgs.hyperfine
          pkgs.cloc
          pkgs.tokei
          pkgs.tree
          pkgs.dust
          pkgs.ncdu
          pkgs.fselect
          pkgs.sd
          pkgs.scooter
          pkgs.kondo
          pkgs.tuxedo
        ];
      };
    };
}
