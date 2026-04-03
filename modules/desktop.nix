{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.desktop =
    { config, pkgs, ... }:
    {
      # Graphics
      hardware.graphics.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      # Display and desktop environment
      services.xserver.enable = true;
      services.displayManager = {
        sddm.enable = true;
        autoLogin.enable = true;
        autoLogin.user = owner.username;
      };
      services.desktopManager.plasma6.enable = true;

      # Keyboard layout
      services.xserver.xkb = {
        layout = "gb,ara,in";
        variant = ",mac,mal_poorna";
      };

      # Printing
      services.printing.enable = true;

      # Sound with pipewire
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # Touchpad
      services.libinput = {
        enable = true;
        touchpad.naturalScrolling = true; # KDE resets this
      };

      # Input remapping (caps → ctrl/esc)
      services.kanata = {
        enable = true;
        keyboards.internalKeyboard = {
          extraDefCfg = "process-unmapped-keys yes";
          config = ''
            (defvar
              tap-time 150
              hold-time 200
            )
            (defalias
              caps (tap-hold 200 200 esc lctl)
            )
            (defsrc
              caps
            )
            (deflayer base
              @caps
            )
          '';
        };
      };

      # HM: wayland clipboard
      home-manager.users.${owner.username} = {
        home.packages = [ pkgs.wl-clipboard ];
      };
    };
}
