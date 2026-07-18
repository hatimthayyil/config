{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.terminals =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        programs = {
          kitty = {
            enable = true;
            shellIntegration.enableBashIntegration = true;
            themeFile = "Modus_Vivendi";
            settings = {
              # lets the tmux theme toggle (prefix + t) flip kitty's colors
              # in sync via `kitten @ set-colors`. The socket is required:
              # tmux run-shell has no TTY, so TTY-based remote control can
              # never reach kitty from a tmux keybinding. kitty appends
              # "-<pid>" to the socket path per instance.
              allow_remote_control = "yes";
              listen_on = "unix:/tmp/kitty-sock";
            };
          };
          ghostty = {
            enable = true;
            enableBashIntegration = true;
            enableFishIntegration = true;
          };
        };

        home.packages = [
          pkgs.unstable.warp-terminal
        ];
      };
    };
}
