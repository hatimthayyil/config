{
  config,
  inputs,
  ...
}:
{
  configurations.nixos.eagle.module = {
    imports =
      (with config.flake.modules.nixos; [
        base
        containers
      ])
      ++ [
        inputs.hardware.nixosModules.lenovo-thinkpad-p52
        ../../hosts/eagle/hardware-configuration.nix
      ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "eagle";
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/London";

    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };

    console.keyMap = "uk";
    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
