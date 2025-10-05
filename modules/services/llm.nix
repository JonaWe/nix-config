{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.myconf.services.llm;
in {
  options.myconf.services.llm = {
    enable = lib.mkEnableOption "Enable llm service";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Opens ports for llm";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/open-webui";
      example = "/var/lib/open-webui";
      description = "Base directory that is used to store open-webui data";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8085;
      example = 8085;
      description = "Port that is used for open webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      # package = pkgs-unstable.ollama;
      loadModels = ["llama3.2:3b" "gemma3:4b" "gemma3:12b" "llama3.2-vision:11b" "deepseek-r1:7b" "deepseek-r1:8b" "phi4:14b" "nomic-embed-text" "dolphin3:8b" "gpt-oss:20b"];

      acceleration = "cuda";
    };

    virtualisation.oci-containers.containers."open-webui" = {
      image = "ghcr.io/open-webui/open-webui";
      environment = {
        "TZ" = "Europe/Berlin";
        "OLLAMA_BASE_URL" = "http://host.docker.internal:${toString 11434}";
        "WEBUI_SECRET_KEY" = "not-important-right-now-for-this-setup";
        "ANONYMIZED_TELEMETRY" = "False";
        "DO_NOT_TRACK" = "True";
        "SCARF_NO_ANALYTICS" = "True";
      };
      ports = [
        "${toString cfg.port}:8080"
      ];
      volumes = [
        "${cfg.dataDir}:/app/backend/data"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
        # "--network=host"
        "--add-host=host.docker.internal:10.1.1.90"
      ];
    };

    services.nginx.virtualHosts."llm.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
        proxyWebsockets = true;
      };
    };
  };
}
