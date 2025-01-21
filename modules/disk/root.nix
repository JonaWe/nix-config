{device}: {
  disko.devices = let
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
      cachefile = "none";
    };
  in {
    disk = {
      nvme = {
        type = "disk";
        inherit device;
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
        inherit options;
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
