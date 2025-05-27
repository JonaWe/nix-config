{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.disk.ext4;
in {
  disko.devices = lib.mkIf cfg.enable {
    disk = {
      sda = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "table";
          format = "msdos";
          partitions = [
            {
              name = "root";
              part-type = "primary";
              start = "1M";
              end = "100%";
              bootable = true;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            }
          ];
        };
      };
    };
  };
}
