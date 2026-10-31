{
  config,
  lib,
  inputs,
  username,
  ...
}: let
  cfg = config.myconf.services.photon-to-memory;
in {
  imports = [inputs.photon-to-memory.nixosModules.default];

  options.myconf.services.photon-to-memory = {
    enable = lib.mkEnableOption "PhotonToMemory learning platform";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8380;
      example = 8380;
      description = "Port used for PhotonToMemory (bound to 127.0.0.1 behind nginx)";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "photon.ts.pinkorca.de";
      description = "Domain of the nginx virtual host";
    };
    resDir = lib.mkOption {
      type = lib.types.str;
      default = "/srv/photon-to-memory/res";
      description = "Directory with the source PDFs, served under /res";
    };
    zfsIntegration.enable = lib.mkEnableOption "own ZFS dataset for the learning data";
    zfsIntegration.enableBackups = lib.mkEnableOption "sanoid snapshots of that dataset";
  };

  config = lib.mkIf cfg.enable {
    services.photon-to-memory = {
      enable = true;
      inherit (cfg) port resDir;
      bind = "127.0.0.1";
      openFirewallOnTailscale = false;
    };

    # DynamicUser keeps its state in /var/lib/private/<name>; the dataset is mounted there.
    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/photon-to-memory" = {
        type = "zfs_fs";
        mountpoint = "/var/lib/private/photon-to-memory";
        # A missing dataset must not drop the production host into emergency mode at boot.
        mountOptions = ["nofail"];
        options.mountpoint = "legacy";
      };
    };
    systemd.services.photon-to-memory.unitConfig.RequiresMountsFor =
      lib.mkIf cfg.zfsIntegration.enable ["/var/lib/private/photon-to-memory"];
    # nofail drops the mount's ordering before local-fs.target; without this a
    # persistent backup timer could write into the empty mount point on zroot.
    systemd.services.photon-to-memory-backup.unitConfig.RequiresMountsFor =
      lib.mkIf cfg.zfsIntegration.enable ["/var/lib/private/photon-to-memory"];

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/photon-to-memory".useTemplate = ["default"];
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/private 0700 root root -"
      "d /srv/photon-to-memory 0755 root root -"
      "d ${cfg.resDir} 0755 ${username} users -"
    ];

    services.nginx.virtualHosts.${cfg.domain} = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
