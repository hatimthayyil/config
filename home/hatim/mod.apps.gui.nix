{
  pkgs,
  ...
}:
{
  programs = {
    # Multimedia
    cmus.enable = true;
    mpv.enable = true;
    imv.enable = true;

    # Documents, PDFs, books, etc
    zathura.enable = true;
    sioyek.enable = true;
    onlyoffice.enable = true;

    # Mail
    thunderbird = {
      enable = true;
      profiles."default" = {
        isDefault = true;
      };
    };
  };

  home.packages = [
    # Utils
    # pkgs.kdePackages.filelight
    pkgs.qdirstat

    # Mail
    pkgs.mailspring

    # Messaging
    pkgs.telegram-desktop
    pkgs.signal-desktop
    pkgs.senpai # IRC
    pkgs.discord
    pkgs.element-desktop
    pkgs.zoom-us

    # Design
    pkgs.drawio
    pkgs.blender

    # FTP
    pkgs.filezilla
  ];
}
