{
  pkgs,
  inputs,
  ...
}: {
  programs = {
    # Browsers
    firefox.enable = true;
    chromium.enable = true; # TODO make sure it uses ungoogled

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
    # Browsers
    pkgs.librewolf
    pkgs.nyxt
    inputs.zen-browser.packages."x86_64-linux".default
    pkgs.tangram

    # Messaging
    pkgs.telegram-desktop
    pkgs.signal-desktop
    pkgs.senpai # IRC

    # Editors
    pkgs.windsurf
    pkgs.code-cursor
    pkgs.vscodium-fhs
  ];
}
