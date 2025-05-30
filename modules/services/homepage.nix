{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  cfg = config.myconf.services.homepage;
in {
  options.myconf.services.homepage = {
    enable = lib.mkEnableOption "Enable homepage dashboard";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for homepage dashboard";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."homepage/environment" = {};

    services.homepage-dashboard = {
      package = pkgs-unstable.homepage-dashboard;
      enable = true;
      allowedHosts = "homepage.home.pinkorca.de,homepage.ts.pinkorca.de";
      environmentFile = config.sops.secrets."homepage/environment".path;
      openFirewall = cfg.openFirewall;
      settings = {
        title = "Homelab Statuspage";
        useEqualHeights = true;
        layout = {
          "Services" = {
            style = "row";
            columns = "4";
          };
          "*arr" = {
            style = "row";
            columns = "4";
          };
          "Network" = {
            style = "row";
            columns = "4";
          };
          "System" = {
            style = "row";
            columns = "4";
          };
        };
      };
      widgets = [
        {
          search = {
            focus = true;
            provider = "duckduckgo";
            showSearchSuggestions = true;
            target = "_blank";
          };
        }
        {
          resources = {
            label = "System";
            cpu = true;
            cputemp = true;
            uptime = true;
            units = "metric";
            memory = true;
            network = true;
          };
        }
        {
          resources = {
            label = "Jellyfin";
            disk = "/data/media/jellyfin";
          };
        }
        {
          resources = {
            label = "Immich";
            disk = "/data/media/immich";
          };
        }
      ];
      services = let
        serverBaseUrl = "ts.pinkorca.de";
      in [
        {
          "Services" = [
            {
              Immich = {
                icon = "immich.png";
                href = "https://immich.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:2283";
                description = "Photo Library";
                widget = {
                  type = "immich";
                  url = "http://localhost:2283";
                  key = "{{HOMEPAGE_VAR_IMMICH_API_KEY}}";
                  version = "2";
                };
              };
            }
            {
              Jellyfin = {
                icon = "jellyfin.png";
                href = "https://jellyfin.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:8096/health";
                description = "Media Streaming";
                widget = {
                  type = "jellyfin";
                  url = "http://localhost:8096";
                  enableBlocks = true;
                  enableNowPlaying = true;
                  enableUser = false;
                  expandOneStreamToTwoRows = false;
                  key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                };
              };
            }
            {
              Gitea = {
                icon = "gitea.png";
                href = "https://gitea.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:3002";
                description = "Git Server";
                widget = {
                  type = "gitea";
                  url = "http://localhost:3002";
                  key = "{{HOMEPAGE_VAR_GITEA_API_KEY}}";
                };
              };
            }
            {
              Tandoor = {
                icon = "tandoor-recipes.png";
                href = "https://recipes.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:9203";
                description = "Recipe Manager";
                widget = {
                  type = "tandoor";
                  url = "http://localhost:9203";
                  key = "{{HOMEPAGE_VAR_TANDOOR_API_KEY}}";
                };
              };
            }
            {
              Paperless = {
                icon = "paperless-ngx.svg";
                href = "https://paperless.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:${toString config.myconf.services.paperless.port}";
                description = "Digital Document Mananger";
                widget = {
                  type = "paperlessngx";
                  url = "http://localhost:${toString config.myconf.services.paperless.port}";
                  username = "admin";
                  password = "admin";
                };
              };
            }
            {
              "Stirling Pdf" = {
                icon = "stirling-pdf.svg";
                href = "https://pdf.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:${toString config.myconf.services.stirling-pdf.port}";
                description = "PDF Multitool";
              };
            }
            {
              "Open WebUI" = {
                icon = "open-webui.svg";
                href = "https://llm.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:${toString config.myconf.services.llm.port}";
                description = "AI Chatbot";
              };
            }
            {
              "Grocy" = {
                icon = "grocy.svg";
                href = "https://grocy.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:${toString config.myconf.services.grocy.port}";
                description = "Household Management";
              };
            }
            {
              "Wallos" = {
                icon = "wallos.svg";
                href = "https://wallos.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:${toString config.myconf.services.wallos.port}";
                description = "Subscription Management";
              };
            }
          ];
        }
        {
          "*arr" = [
            {
              Radarr = {
                icon = "radarr.png";
                href = "https://radarr.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:7878";
                description = "Movie Manager";
                widget = {
                  type = "radarr";
                  url = "http://localhost:7878";
                  key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
                  # enableQueue = "true";
                };
              };
            }
            {
              Readarr = {
                icon = "readarr.png";
                href = "https://readarr.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:8787";
                description = "Book Manager";
                widget = {
                  type = "readarr";
                  url = "http://localhost:8787";
                  key = "{{HOMEPAGE_VAR_READARR_API_KEY}}";
                };
              };
            }
            {
              Sonarr = {
                icon = "sonarr.png";
                href = "https://sonarr.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:8989";
                description = "TV Show Manager";
                widget = {
                  type = "sonarr";
                  url = "http://localhost:8989";
                  key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
                  # enableQueue = "true";
                };
              };
            }
            {
              Prowlarr = {
                icon = "prowlarr.png";
                href = "https://prowlarr.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:9696";
                description = "Index Manager";
                widget = {
                  type = "prowlarr";
                  url = "http://localhost:9696";
                  key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
                };
              };
            }
            {
              Jellyseerr = {
                icon = "jellyseerr.png";
                href = "https://jellyseerr.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:5055";
                description = "Media Requests";
                widget = {
                  type = "jellyseerr";
                  url = "http://localhost:5055";
                  key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
                };
              };
            }
            {
              Recommendarr = {
                icon = "recommendarr.png";
                href = "https://recommendarr.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:8765";
                description = "Media Reccomendations";
              };
            }
            {
              qBittorrent = {
                icon = "qbittorrent.png";
                href = "https://qbittorrent.${serverBaseUrl}/";
                statusStyle = "dot";
                siteMonitor = "http://localhost:8080";
                description = "Torrent Download Client";
                widget = {
                  type = "qbittorrent";
                  url = "http://localhost:8080";
                  username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
                };
              };
            }
          ];
        }
        {
          "Network" = [
            {
              "OPNSense" = {
                icon = "opnsense.png";
                href = "https://10.1.1.1/";
                statusStyle = "dot";
                siteMonitor = "https://10.1.1.1";
                description = "Router";
                widget = {
                  type = "opnsense";
                  url = "https://10.1.1.1";
                  username = "{{HOMEPAGE_VAR_OPNSENSE_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_OPNSENSE_PASSWORD}}";
                  key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
                };
              };
            }
          ];
        }
        {
          "System" = [
          ];
        }
      ];
      bookmarks = [
        {
          Developer = [
            {
              Github = [
                {
                  icon = "si-github";
                  href = "https://github.com/";
                }
              ];
            }
            {
              "Nixos Search" = [
                {
                  icon = "si-nixos";
                  href = "https://search.nixos.org/packages";
                }
              ];
            }
            {
              "Nixos Wiki" = [
                {
                  icon = "si-nixos";
                  href = "https://nixos.wiki/";
                }
              ];
            }
          ];
        }
        {
          Entertainment = [
            {
              YouTube = [
                {
                  icon = "si-youtube";
                  href = "https://youtube.com/";
                }
              ];
            }
          ];
        }
      ];
    };

    services.nginx.virtualHosts."homepage.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8082/";
      };
    };
    services.nginx.virtualHosts."homepage.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8082/";
      };
    };
  };
}
