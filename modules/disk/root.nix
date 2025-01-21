{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.disk.rootPool;
in {
  disko.devices = lib.mkIf cfg.enable {
    disk = {
      nvme = {
        type = "disk";
        device = cfg.drive;
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
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "";
        options = {
          ashift = "12";
          autotrim = "on";
          cachefile = "none";
        };
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          canmount = "off";
          mountpoint = "none";
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
          "root/log" = {
            mountpoint = "/var/log";
            options.mountpoint = "legacy";
            type = "zfs_fs";
          };
          "root/lib" = {
            mountpoint = "/var/lib";
            options.mountpoint = "legacy";
            type = "zfs_fs";
          };
        };
      };
    };
  };
}
