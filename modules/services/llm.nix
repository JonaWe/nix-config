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

    services.open-webui = {
      enable = true;
      package = pkgs-unstable.open-webui;
      port = cfg.port;
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
