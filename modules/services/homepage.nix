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
      package = pkgs.homepage-dashboard;
      enable = true;
      allowedHosts = "homepage.home.pinkorca.de,homepage.ts.pinkorca.de";
      environmentFile = config.sops.secrets."homepage/environment".path;
      openFirewall = cfg.openFirewall;
      settings = {
        title = "Homelab Statuspage";
        useEqualHeights = true;

        # optional other appearance settings:
        theme = "dark";
        color = "slate";
        iconStyle = "theme";
        statusStyle = "dot";

        layout = [
          {
            "Network" = {
              # style = "row";
              style = "column";
              columns = "1";
            };
          }
          {
            "System" = {
              # style = "row";
              style = "column";
              columns = "1";
            };
          }
          {
            "*arr" = {
              # style = "row";
              # columns = "4";
              style = "column";
              columns = "1";
            };
          }
          {
            "Tools" = {
              style = "column";
              columns = "1";
            };
          }
          {
            "Services" = {
              style = "row";
              columns = "4";
            };
          }
        ];
      };
      widgets = [
        {
          search = {
            focus = true;
            provider = "custom";
            url = "https://search.ts.pinkorca.de/search?q=";
            target = "_blank";
            suggestionUrl = "https://ac.ecosia.org/autocomplete?type=list&q=";
            showSearchSuggestions = true;
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
                siteMonitor = "http://localhost:8096/health";
                description = "Movies and TV shows";
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
              Navidrome = {
                icon = "navidrome.png";
                href = "https://navidrome.${serverBaseUrl}/";
                siteMonitor = "http://localhost:4533/health";
                description = "Music Streaming";
                widget = {
                  type = "navidrome";
                  url = "http://localhost:4533";
                  user = "{{HOMEPAGE_VAR_NAVIDROME_USER}}";
                  token = "{{HOMEPAGE_VAR_NAVIDROME_TOKEN}}";
                  salt = "{{HOMEPAGE_VAR_NAVIDROME_SALT}}";
                };
              };
            }
            {
              Actual = {
                icon = "actual-budget.png";
                href = "https://actual.${serverBaseUrl}/";
                siteMonitor = "http://localhost:9284";
                description = "Money Budgeting";
              };
            }
            {
              Gitea = {
                icon = "gitea.png";
                href = "https://gitea.${serverBaseUrl}/";
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
              Audiobookshelf = {
                icon = "audiobookshelf.png";
                href = "https://audiobookshelf.${serverBaseUrl}/";
                siteMonitor = "http://localhost:8654";
                description = "Audio Books and Books";
                widget = {
                  type = "audiobookshelf";
                  url = "http://localhost:8654";
                  key = "{{HOMEPAGE_VAR_AUDIOBOOKSHELF_API_KEY}}";
                };
              };
            }
            {
              Tandoor = {
                icon = "tandoor-recipes.png";
                href = "https://recipes.${serverBaseUrl}/";
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
                siteMonitor = "http://localhost:${toString config.myconf.services.paperless.port}";
                description = "Digital Document Mananger";
                widget = {
                  type = "paperlessngx";
                  url = "http://localhost:${toString config.myconf.services.paperless.port}";
                  username = "{{HOMEPAGE_VAR_PAPERLESS_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_PAPERLESS_PASSWORD}}";
                };
              };
            }
            {
              SearX = {
                href = "https://search.ts.pinkorca.de";
                icon = "searx.svg";
                siteMonitor = "http://localhost:${toString config.myconf.services.searx.port}";
                description = "Meta Search Enging";
              };
            }
            # {
            #   Karakeep = {
            #     href = "https://karakeep.ts.pinkorca.de";
            #     icon = "karakeep.svg";
            #     siteMonitor = "http://localhost:${toString config.myconf.services.karakeep.port}";
            #     description = "Bookmark Mananger";
            #   };
            # }
            {
              "Open WebUI" = {
                icon = "open-webui.svg";
                href = "https://llm.${serverBaseUrl}/";
                siteMonitor = "http://localhost:${toString config.myconf.services.llm.port}";
                description = "AI Chatbot";
              };
            }
            {
              "Grocy" = {
                icon = "grocy.svg";
                href = "https://grocy.${serverBaseUrl}/";
                siteMonitor = "http://localhost:${toString config.myconf.services.grocy.port}";
                description = "Household Management";
              };
            }
            {
              "Wallos" = {
                icon = "sh-wallos.svg";
                href = "https://wallos.${serverBaseUrl}/";
                siteMonitor = "http://localhost:${toString config.myconf.services.wallos.port}";
                description = "Subscription Management";
              };
            }
          ];
        }
        {
          "Tools" = [
            {
              "Picard" = {
                icon = "sh-musicbrainz-picard.png";
                href = "https://picard.${serverBaseUrl}/";
                siteMonitor = "http://localhost:5800";
                description = "Music Metadata Management";
              };
            }
            {
              "Metube" = {
                icon = "metube.svg";
                href = "https://metube.${serverBaseUrl}/";
                siteMonitor = "http://localhost:${toString config.myconf.services.metube.port}";
                description = "YouTube Downloader";
              };
            }
            {
              "Stirling Pdf" = {
                icon = "stirling-pdf.svg";
                href = "https://pdf.${serverBaseUrl}/";
                siteMonitor = "http://localhost:${toString config.myconf.services.stirling-pdf.port}";
                description = "PDF Multitool";
              };
            }
            {
              "ConvertX" = {
                icon = "sh-convertx.png";
                href = "https://convert.${serverBaseUrl}/";
                siteMonitor = "http://localhost:${toString config.myconf.services.convertx.port}";
                description = "Convert any file";
              };
            }
            {
              "Omni-Tools" = {
                icon = "omni-tools.png";
                href = "https://tools.${serverBaseUrl}/";
                siteMonitor = "http://localhost:${toString config.myconf.services.omni-tools.port}";
                description = "General purpose tools";
              };
            }
            {
              "IT-Tools" = {
                icon = "it-tools.svg";
                href = "https://it-tools.${serverBaseUrl}/";
                siteMonitor = "http://localhost:${toString config.myconf.services.it-tools.port}";
                description = "Collection of it tools";
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
            # {
            #   Readarr = {
            #     icon = "readarr.png";
            #     href = "https://readarr.${serverBaseUrl}/";
            #     siteMonitor = "http://localhost:8787";
            #     description = "Book Manager";
            #     widget = {
            #       type = "readarr";
            #       url = "http://localhost:8787";
            #       key = "{{HOMEPAGE_VAR_READARR_API_KEY}}";
            #     };
            #   };
            # }
            {
              Sonarr = {
                icon = "sonarr.png";
                href = "https://sonarr.${serverBaseUrl}/";
                siteMonitor = "http://localhost:8989";
                description = "TV Show Manager";
                widget = {
                  type = "sonarr";
                  url = "http://localhost:8989";
                  key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
                };
              };
            }
            {
              Prowlarr = {
                icon = "prowlarr.png";
                href = "https://prowlarr.${serverBaseUrl}/";
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
              slskd = {
                icon = "slskd.png";
                href = "https://slskd.${serverBaseUrl}/";
                siteMonitor = "http://localhost:5030";
                description = "Music Sharing";
                widget = {
                  type = "slskd";
                  url = "http://localhost:5030";
                  key = "{{HOMEPAGE_VAR_SLSKD_API_KEY}}";
                };
              };
            }
            {
              dispatcharr = {
                icon = "dispatcharr.png";
                href = "https://dispatcharr.${serverBaseUrl}/";
                siteMonitor = "http://localhost:9191";
                description = "IPTV Aggregation";
              };
            }
            {
              Jellyseerr = {
                icon = "jellyseerr.png";
                href = "https://jellyseerr.${serverBaseUrl}/";
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
              sabnzbd = {
                icon = "sabnzbd.png";
                href = "https://sabnzbd.${serverBaseUrl}/";
                siteMonitor = "http://localhost:${toString config.myconf.services.arr.sabnzbd.port}";
                description = "NZB Download Client";
                widget = {
                  type = "sabnzbd";
                  url = "http://localhost:${toString config.myconf.services.arr.sabnzbd.port}";
                  key = "{{HOMEPAGE_VAR_SABNZBD_KEY}}";
                };
              };
            }
            {
              qBittorrent = {
                icon = "qbittorrent.png";
                href = "https://qbittorrent.${serverBaseUrl}/";
                siteMonitor = "http://localhost:8055";
                description = "Torrent Download Client";
                widget = {
                  type = "qbittorrent";
                  url = "http://localhost:8055";
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
                siteMonitor = "http://10.1.1.1";
                description = "Router";
                widget = {
                  type = "opnsense";
                  url = "http://10.1.1.1";
                  username = "{{HOMEPAGE_VAR_OPNSENSE_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_OPNSENSE_PASSWORD}}";
                  key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
                };
              };
            }
            {
              "Unifi Controller" = {
                icon = "unifi.svg";
                href = "https://10.1.1.90:8443/";
                siteMonitor = "https://ant:8443";
                description = "Unifi Controller";
                widget = {
                  type = "unifi";
                  url = "https://ant:8443";
                  username = "homepage";
                  password = "homepage";
                  uptime = true;
                  wlan = true;
                  wlan_users = true;
                  wlan_devices = true;
                };
              };
            }
            {
              "Adguard Home" = {
                icon = "adguard-home.svg";
                href = "http://10.1.1.1:3000/";
                siteMonitor = "http://10.1.1.1:3000";
                description = "DNS adblocker";
                # widget = {
                #   type = "adguard";
                #   url = "http://10.1.1.1:3000";
                #   username = "{{HOMEPAGE_VAR_ADGUARD_USERNAME}}";
                #   password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
                #   queries = true;
                #   blocked = true;
                #   filtered = true;
                #   latency = true;
                # };
              };
            }
          ];
        }
        {
          "System" = [
            {
              "Olivetin" = {
                icon = "olivetin.svg";
                href = "https://olivetin.${serverBaseUrl}/";
                siteMonitor = "https://qbittorrent.${serverBaseUrl}/";
                description = "Server Commands";
              };
            }
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
