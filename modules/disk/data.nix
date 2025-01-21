{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.disk.dataPool;
  dataDiskConfig = builtins.listToAttrs (builtins.map (device: {
      name = "dataDrive:" + device;
      value = {
        type = "disk";
        inherit device;
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
    cfg.devices);
  rootFsOptions = {
    acltype = "posixacl";
    atime = "off";
    canmount = "off";
    compression = "zstd";
    mountpoint = "none";
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
  disko.devices = lib.mkIf cfg.enable {
    disk = dataDiskConfig;
    zpool = {
      zdata = {
        mode = "raidz1";
        inherit options;
        inherit rootFsOptions;
        datasets = {
          "enc" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              canmount = "off";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "prompt";
            };
          };
          "plain" =
            {
              type = "zfs_fs";
              options = {
                mountpoint = "none";
                canmount = "off";
              };
            }
            // config.myconf.disk.extraDatasets;
        };
      };
    };
  };
}
