# /dev/disk/by-id/ata-SanDisk_SDSSDA240G_163623441801
# /dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNL0T513845T
# /dev/disk/by-id/wwn-0x50004cf206c95bfa
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNL0T513845T";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"]; # Override existing partition
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "@" = {
                    mountpoint = "/";
                  };
                  # Subvolume name is the same as the mountpoint
                  "@home" = {
                    mountOptions = ["compress=zstd"];
                    mountpoint = "/home";
                  };
                  # Parent is not mounted so the mountpoint must be set
                  "@nix" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/nix";
                  };
                };
              };
            };
          };
        };
      };
      data = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SanDisk_SDSSDA240G_163623441801";
        content = {
          type = "gpt";
          partitions = {
            files = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zdata";
              };
            };
          };
        };
      };
      data2 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x50004cf206c95bfa";
        content = {
          type = "gpt";
          partitions = {
            files = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zdata";
              };
            };
          };
        };
      };
    };
    zpool = {
      zdata = {
        type = "zpool";
        rootFsOptions = {
          canmount = "off";
        };
        datasets = {
          samba = {
            type = "zfs_fs";
            mountpoint = "/data/samba";
            options.mountpoint = "legacy";
          };
          media = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/data/media";
          };
        };
      };
    };
  };
}
