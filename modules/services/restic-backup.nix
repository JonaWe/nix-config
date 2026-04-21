{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab;

  backupDatasets = lib.flatten (lib.mapAttrsToList (
      name: svc: let
        backupMounts = lib.filterAttrs (mp: opts: opts.backup) svc.zfsMounts;
      in
        map (opts: opts.dataset) (lib.attrValues backupMounts)
    )
    cfg.services);

  datasetString = builtins.concatStringsSep " " backupDatasets;
in
  lib.mkIf (cfg.enable && backupDatasets != []) {
    # *node_modules*
    environment.etc."restic-excludes.txt".text = ''
      *.tmp
      *.swp
      /mnt/restic_backups/zdata/enc/services/jellyfin3/config/metadata
    '';

    sops.secrets."restic/backup-fabian/environment" = {};

    systemd.services.restic-zfs-backup = {
      description = "Offsite Restic backup of ZFS snapshots";
      after = ["network-online.target"];
      wants = ["network-online.target"];

      path = with pkgs; [zfs restic util-linux coreutils jq];

      serviceConfig = {
        Type = "oneshot";
        User = "root";

        EnvironmentFile = config.sops.secrets."restic/backup-fabian/environment".path;
      };

      environment = {
        ZFS_DATASETS = datasetString;
      };

      script = builtins.readFile ./restic-backup.sh;
    };

    systemd.timers.restic-zfs-backup = {
      description = "Run Restic ZFS backup daily at 3 AM";
      wantedBy = ["timers.target"];

      timerConfig = {
        OnCalendar = "*-*-* 03:15:00";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };
  }
