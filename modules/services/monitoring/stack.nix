{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.monitoring;

  # Config is delivered through environment.etc rather than a tmpfiles copy:
  # an explicit mode yields a real regular file that is rebuilt on every
  # activation, which a bind mount can pick up.
  etcFile = source: {
    inherit source;
    mode = "0444";
  };

  dataset = name: {
    "/opt/services/monitoring/${name}/data" = {
      dataset = "zdata/enc/services/monitoring/${name}";
      snapshot = true;
      # Metrics and logs are regenerable; Grafana holds user settings.
      backup = name == "grafana";
    };
  };
in {
  imports = [../homelab.nix];

  config = lib.mkIf (cfg.stack.enable && config.homelab.enable) {
    environment.etc = {
      "monitoring/prometheus/prometheus.yml" = etcFile ./config/prometheus/prometheus.yml;
      "monitoring/prometheus/rules/units.yml" = etcFile ./config/prometheus/rules/units.yml;
      "monitoring/prometheus/rules/storage.yml" = etcFile ./config/prometheus/rules/storage.yml;
      "monitoring/prometheus/rules/stack.yml" = etcFile ./config/prometheus/rules/stack.yml;
      "monitoring/prometheus/rules/updates.yml" = etcFile ./config/prometheus/rules/updates.yml;

      "monitoring/loki/loki.yml" = etcFile ./config/loki/loki.yml;
      # Single-tenant Loki reads rules from <dir>/fake/.
      "monitoring/loki/rules/fake/security.yml" = etcFile ./config/loki/rules/fake/security.yml;
      "monitoring/loki/rules/fake/containers.yml" = etcFile ./config/loki/rules/fake/containers.yml;

      "monitoring/alertmanager/alertmanager.yml" = etcFile ./config/alertmanager/alertmanager.yml;

      "monitoring/diun/diun.yml" = etcFile ./config/diun/diun.yml;
      "monitoring/diun/images.yml" = etcFile cfg.updates.imageList;

      "monitoring/grafana/provisioning/datasources/datasources.yml" = etcFile ./config/grafana/datasources.yml;
      "monitoring/grafana/provisioning/dashboards/dashboards.yml" = etcFile ./config/grafana/dashboards.yml;
      "monitoring/grafana/dashboards/homelab-overview.json" = etcFile ./config/grafana/dashboards/homelab-overview.json;
      "monitoring/grafana/dashboards/services-units.json" = etcFile ./config/grafana/dashboards/services-units.json;
      "monitoring/grafana/dashboards/storage-zfs.json" = etcFile ./config/grafana/dashboards/storage-zfs.json;
      "monitoring/grafana/dashboards/host.json" = etcFile ./config/grafana/dashboards/host.json;
      "monitoring/grafana/dashboards/logs.json" = etcFile ./config/grafana/dashboards/logs.json;
      "monitoring/grafana/dashboards/updates.json" = etcFile ./config/grafana/dashboards/updates.json;
    };

    homelab.services = {
      prometheus = {
        containerFile = ./prometheus.container;
        rootless = true;
        user = "prometheus";
        group = "prometheus";
        port = 9090;
        zfsMounts = dataset "prometheus";
      };

      loki = {
        containerFile = ./loki.container;
        rootless = true;
        user = "loki";
        group = "loki";
        port = 3100;
        zfsMounts = dataset "loki";
      };

      alertmanager = {
        containerFile = ./alertmanager.container;
        rootless = true;
        user = "alertmanager";
        group = "alertmanager";
        port = 9093;
        zfsMounts = dataset "alertmanager";
      };

      diun = lib.mkIf cfg.updates.enable {
        containerFile = ./diun.container;
        rootless = true;
        user = "diun";
        group = "diun";
        port = 9095;
        zfsMounts = dataset "diun";
      };

      grafana = {
        containerFile = ./grafana.container;
        rootless = true;
        user = "grafana";
        group = "grafana";
        port = 3000;
        zfsMounts = dataset "grafana";

        nginx = {
          enable = true;
          domain = "grafana.ts.pinkorca.de";
          websockets = true;
        };
      };
    };
  };
}
