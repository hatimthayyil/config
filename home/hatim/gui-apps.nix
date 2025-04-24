{
  pkgs,
  ...
}: {
  programs = {
    # Multimedia
    cmus.enable = true;
    mpv.enable = true;
    imv.enable = true;

    sioyek.enable = true;

    # Mail
    thunderbird = {
      enable = true;
      profiles."default" = {
        isDefault = true;
      };
    };
  };

  home.packages = [
    # Mail
    pkgs.mailspring

    # Messaging
    pkgs.telegram-desktop
    pkgs.signal-desktop
    pkgs.senpai # IRC
    pkgs.discord
    pkgs.element-desktop
    pkgs.zoom-us

    # Editors
    pkgs.windsurf
    pkgs.code-cursor
    pkgs.vscodium-fhs

    # Design
    pkgs.drawio
  ];
}
