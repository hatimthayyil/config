# modules/disko.nix — declarative disk topology for eagle (disko).
#
# Currently describes the secondary Samsung SSD as a LUKS-encrypted btrfs data
# volume mounted at /hatimthayyil. The boot/root nvme can be migrated here in the
# future, replacing the hand-written fileSystems in
# hosts/eagle/hardware-configuration.nix.
#
# NOTE: the device serial below is eagle-specific. If a second host is added,
# split this into per-host disko modules.
{ inputs, ... }:
{
  flake.modules.nixos.disko = {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk.data = {
      type = "disk";
      device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S2RBNX0J236551B";
      content = {
        type = "gpt";
        partitions.luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "hatimthayyil";
            # Secondary disk: do NOT unlock in initrd. The keyfile lives on the
            # encrypted root, which only becomes readable in stage-2. Unlock is
            # done via /etc/crypttab below, after root is mounted.
            initrdUnlock = false;
            settings = {
              keyFile = "/etc/secrets/hatimthayyil.key";
              allowDiscards = true;
            };
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes."/hatimthayyil" = {
                mountpoint = "/hatimthayyil";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                  "nofail"
                ];
              };
            };
          };
        };
      };
    };

    # Stage-2 unlock: by now the encrypted root is mounted, so the keyfile is
    # readable. systemd opens /dev/mapper/hatimthayyil, then the disko-generated
    # fileSystems."/hatimthayyil" mount proceeds. nofail prevents a key/disk
    # problem from blocking boot to an otherwise-usable system.
    environment.etc."crypttab".text = ''
      hatimthayyil /dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S2RBNX0J236551B-part1 /etc/secrets/hatimthayyil.key luks,discard,nofail
    '';
  };
}
