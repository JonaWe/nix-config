{
  disko.devices = let
    dataDrives = [
      "/dev/disk/by-id/ata-ST16000NM001G-2KK103_WL20TJNQ"
      "/dev/disk/by-id/ata-ST16000NM001G-2KK103_ZL2NZAQ8"
      "/dev/disk/by-id/ata-ST16000NM001G-2KK103_WL20VP3M"
    ];
    dataDiskConfig = builtins.listToAttrs (builtins.map (drive: {
        name = "dataDrive:" + drive;
        value = {
          type = "disk";
          device = drive;
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
      })
      dataDrives);
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
    options = {
      ashift = "12";
      autotrim = "on";
    };
  in {
    disk =
      {
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
      }
      // dataDiskConfig;
    zpool = {
      zroot = {
        type = "zpool";
        mode = "";
        options =
          options
          // {
            cachefile = "none";
          };
        inherit rootFsOptions;
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
        };
      };
      zdata = {
        mode = "raidz1";
        inherit options;
        inherit rootFsOptions;
        datasets = {
          encrypted = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              canmount = "off";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "prompt";
            };
          };
          unencrypted = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              canmount = "off";
            };
          };
          "encrypted/samba" = {
            type = "zfs_fs";
            mountpoint = "/data/samba";
            options.mountpoint = "legacy";
          };
          "encrypted/media" = {
            type = "zfs_fs";
            mountpoint = "/data/media";
            options.mountpoint = "legacy";
            options.recordsize = "1M";
          };
          "encrypted/syncthing" = {
            type = "zfs_fs";
            mountpoint = "/data/syncthing";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
