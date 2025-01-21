{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.disk;
in {
  imports = [
    ./root.nix
    ./data.nix
  ];

  options.myconf.disk = {
    enable = lib.mkEnableOption "Enable disk management with disko";
    hostId = lib.mkOption {
      type = lib.types.str;
      default = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
      description = "HostId used for zfs. Defualt is md5 hash of hostname";
    };
    backups.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable sanoid backup service. This still has to be configured for each dataset";
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
        type = lib.types.listOf lib.types.str;
        description = "List of Identifier for the devices that are used for the data pool";
      };
      extraDatasets = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Extra datasets that sould be added to the zfs zdata pool";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.hostId = cfg.hostId;
    boot.supportedFilesystems = ["zfs"];
    services.sanoid = {
      enable = cfg.backups.enable;
      templates = {
        default = {
          daily = 7;
          hourly = 23;
          weekly = 4;
          monthly = 3;
        };
      };
  #   datasets = {
  #     "zdata/samba".useTemplate = ["default"];
  #   };
    };
  };
}
