{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myconf.services.monitoring;

  onZfs = config.myconf.disk.enable;

  ntfyPost = topic: title: priority: tags: body: ''
    ${pkgs.curl}/bin/curl -fsS --max-time 10 \
      -H "Title: ${title}" \
      -H "Priority: ${priority}" \
      -H "Tags: ${tags}" \
      -d ${body} \
      "${cfg.ntfy.url}/${topic}" >/dev/null || true
  '';

  # smartd invokes this via -M exec with SMARTD_* set in the environment.
  smartdNotify = pkgs.writeShellScript "smartd-ntfy" ''
    ${ntfyPost cfg.ntfy.topics.storage "SMART: $SMARTD_DEVICESTRING" "urgent" "rotating_light,floppy_disk" "\"$SMARTD_FULLMESSAGE\""}
  '';

  # node_exporter's default exclusions, plus podman's transient healthcheck units.
  unitExclude = ".+\\.(automount|device|mount|scope|slice)|[0-9a-f]{64}-[0-9a-f]{16}\\..+";
in {
  options.myconf.services.monitoring = {
    agents.enable = lib.mkEnableOption "Host-level monitoring agents (exporters, log shipping, disk health)";
    stack.enable = lib.mkEnableOption "The monitoring stack itself (Prometheus, Loki, Grafana, Alertmanager)";
    smart.enable = lib.mkEnableOption "SMART monitoring and scheduled self-tests. Off for VPS hosts without real disks";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Address the exporters bind to. The upstream default is 0.0.0.0, which
        would publish them to the LAN. Set this to the tailnet address on hosts
        that are scraped remotely, and open the port on tailscale0 only.
      '';
    };

    ntfy = {
      url = lib.mkOption {
        type = lib.types.str;
        default = "http://127.0.0.1:8019";
        description = "Base URL of the ntfy instance used as alert channel";
      };
      topics = {
        alerts = lib.mkOption {
          type = lib.types.str;
          default = "homelab-alerts";
          description = "Topic for Alertmanager notifications";
        };
        updates = lib.mkOption {
          type = lib.types.str;
          default = "homelab-updates";
          description = "Topic for container image update notices";
        };
        storage = lib.mkOption {
          type = lib.types.str;
          default = "homelab-storage";
          description = ''
            Topic for ZED and smartd. Deliberately independent of Prometheus so
            disk and pool events still arrive when the stack itself is down.
          '';
        };
      };
    };

    updates = {
      enable = lib.mkEnableOption "Daily report of running versus available image versions";
      schedule = lib.mkOption {
        type = lib.types.str;
        default = "05:00";
        description = "When to query the registries. Daily keeps anonymous rate limits comfortable";
      };
    };

    loki.pushUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:3100/loki/api/v1/push";
      description = "Where Alloy pushes journal logs. Remote hosts point this at the stack host over the tailnet";
    };
  };

  config = lib.mkIf cfg.agents.enable (lib.mkMerge [
    {
      services.prometheus.exporters.node = {
        enable = true;
        inherit (cfg) listenAddress;
        enabledCollectors = ["systemd" "textfile" "processes"];
        extraFlags = [
          "--collector.systemd.enable-restarts-metrics"
          "--collector.systemd.unit-exclude=${unitExclude}"
          "--collector.textfile.directory=/var/lib/node-exporter/textfile"
        ];
      };

      systemd.tmpfiles.rules = ["d /var/lib/node-exporter/textfile 0755 root root -"];

      # node_exporter's systemd collector sees the system manager only.
      systemd.services.user-unit-sweep = {
        description = "Collect systemd unit state from per-user managers";
        path = with pkgs; [systemd coreutils gawk gnugrep];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash ${./scripts/user-unit-sweep.sh}";
        };
      };

      systemd.services.image-versions = lib.mkIf cfg.updates.enable {
        description = "Compare running image versions against the registries";
        path = with pkgs; [skopeo podman docker util-linux systemd coreutils gawk gnugrep];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash ${./scripts/image-versions.sh}";
          TimeoutStartSec = "30m";
          WorkingDirectory = "/";
        };
      };

      systemd.timers.image-versions = lib.mkIf cfg.updates.enable {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = cfg.updates.schedule;
          RandomizedDelaySec = "30m";
          Persistent = true;
        };
      };

      systemd.timers.user-unit-sweep = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "2min";
          OnUnitActiveSec = "60s";
          AccuracySec = "10s";
        };
      };

      services.alloy = {
        enable = true;
        configPath = "/etc/alloy/config.alloy";
        extraFlags = ["--disable-reporting"];
      };

      environment.etc."alloy/config.alloy" = {
        source = ./config/alloy/config.alloy;
        mode = "0444";
      };

      systemd.services.alloy.environment.ALLOY_LOKI_URL = cfg.loki.pushUrl;
    }

    (lib.mkIf cfg.smart.enable {
      environment.systemPackages = with pkgs; [smartmontools hdparm];

      services.prometheus.exporters.smartctl = {
        enable = true;
        inherit (cfg) listenAddress;
      };

      services.smartd = {
        enable = true;
        autodetect = true;

        # Any of these enabled makes the module prepend its own
        # "-m <nomailer> -M exec <script>", shadowing ours below.
        notifications = {
          wall.enable = false;
          mail.enable = false;
          x11.enable = false;
        };

        # -s takes a regex matched against T/MM/DD/d/HH, not cron fields.
        # -M is rejected without an accompanying -m; see smartd.conf(5).
        defaults.monitored = lib.concatStringsSep " " [
          "-a"
          "-o on"
          "-S on"
          "-W 4,45,55"
          "-s (S/../.././02|L/../(1[5-9]|2[01])/7/03)"
          "-m <nomailer>"
          "-M exec ${smartdNotify}"
        ];
      };
    })

    (lib.mkIf onZfs {
      services.prometheus.exporters.zfs = {
        enable = true;
        inherit (cfg) listenAddress;
      };

      services.zfs.autoScrub = {
        enable = true;
        interval = "monthly";
      };

      services.zfs.zed.settings = {
        ZED_NTFY_URL = cfg.ntfy.url;
        ZED_NTFY_TOPIC = cfg.ntfy.topics.storage;
        # scrub_finish-notify.sh stays silent on a healthy pool without this.
        ZED_NOTIFY_VERBOSE = true;
      };
    })

  ]);
}
