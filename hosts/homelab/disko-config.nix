# /dev/disk/by-id/ata-SanDisk_SDSSDA240G_163623441801
# /dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNL0T513845T
# /dev/disk/by-id/wwn-0x50004cf206c95bfa
{
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNL0T513845T";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "1024M";
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
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      # data = {
      #   type = "disk";
      #   device = "/dev/disk/by-id/ata-SanDisk_SDSSDA240G_163623441801";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       files = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zdata";
      #         };
      #       };
      #     };
      #   };
      # };
      # data2 = {
      #   type = "disk";
      #   device = "/dev/disk/by-id/wwn-0x50004cf206c95bfa";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       files = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zdata";
      #         };
      #       };
      #     };
      #   };
      # };
    };
    zpool = {
      zroot = {
        type = "zpool";
        options.cachefile = "none";
        mode = "";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          canmount = "off";
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
        };
        datasets = {
          "root" = {
            mountpoint = "/";
            options.mountpoint = "legacy";
            type = "zfs_fs";
          };

          "root/nix" = {
            mountpoint = "/nix";
            options.mountpoint = "legacy";
            type = "zfs_fs";
          };
          "root/home" = {
            mountpoint = "/home";
            options.mountpoint = "legacy";
            type = "zfs_fs";
          };
          "root/var-log" = {
            mountpoint = "/var/log";
            options.mountpoint = "legacy";
            type = "zfs_fs";
          };
          reserved = {
            type = "zfs_fs";
            options.refreservation = "10G";
          };
        };
      };
      # zdata = {
      #   type = "zpool";
      #   rootFsOptions = {
      #     canmount = "off";
      #     "com.sun:auto-snapshot" = "false";
      #   };
      #   datasets = {
      #     encrypted = {
      #       type = "zfs_fs";
      #       options = {
      #         mountpoint = "none";
      #         canmount = "off";
      #         encryption = "aes-256-gcm";
      #         keyformat = "passphrase";
      #         keylocation = "prompt";
      #       };
      #     };
      #     "encrypted/samba" = {
      #       type = "zfs_fs";
      #       mountpoint = "/data/samba";
      #       options.mountpoint = "legacy";
      #     };
      #     "encrypted/media" = {
      #       type = "zfs_fs";
      #       mountpoint = "/data/media";
      #       options.mountpoint = "legacy";
      #     };
      #     "encrypted/syncthing" = {
      #       type = "zfs_fs";
      #       mountpoint = "/data/syncthing";
      #       options.mountpoint = "legacy";
      #     };
      #   };
      # };
    };
  };
}
