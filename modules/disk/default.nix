{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.disk;
in {
  options.myconf.disk = {
    enable = lib.mkEnableOption "Enable disk management with disko";
    extraDatasets = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra datasets that sould be added to the zfs zdata pool";
    };
    hostId = lib.mkOption {
      type = lib.types.str;
      default = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
      description = "HostId used for zfs. Defualt is md5 hash of hostname";
    };
    rootPool = {
      enable = lib.mkEnableOption "Enable root pool with zfs";
      drive = lib.mkOption {
        type = lib.types.str;
        description = "Identifier for the device that is used for the root pool";
      };
    };
    dataPool = {
      enable = lib.mkEnableOption "Enable data pool with zfs";
      drives = lib.mkOption {
        type = lib.types.listOf;
        description = "List of Identifier for the devices that are used for the data pool";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.hostId = cfg.hostId;
    boot.supportedFilesystems = ["zfs"];
    imports = [
      ./root.nix {device = cfg.rootPool.drive;}
      ./data.nix {devices = cfg.dataPool.drives;}
    ];
    # device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNL0T513845T";
    # dataDrives = [
    #   "/dev/disk/by-id/ata-ST16000NM001G-2KK103_WL20TJNQ"
    #   "/dev/disk/by-id/ata-ST16000NM001G-2KK103_ZL2NZAQ8"
    #   "/dev/disk/by-id/ata-ST16000NM001G-2KK103_WL20VP3M"
    # ];
  };
}
