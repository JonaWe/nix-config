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
      environmentFile = config.sops.secrets."homepage/environment".path;
      openFirewall = cfg.openFirewall;
      settings = {
        # base = "https://example.com";
        title = "Homelab Status";
        useEqualHeights = true;
        layout = {
          Media = {
            style = "row";
            columns = "4";
          };
          "*arr" = {
            style = "row";
            columns = "4";
          };
          System = {
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
            units = "metric";
            memory = true;
          };
        }
      ];
      services = let
        serverIp = "192.168.188.117";
      in [
        {
          "*arr" = [
            {
              Radarr = {
                icon = "radarr.png";
                href = "http://${serverIp}:7878/";
                statusStyle = "dot";
                # ping = "192.168.188.117:8096";
                description = "Movie Manager";
                widget = {
                  type = "radarr";
                  url = "http://localhost:7878";
                  key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
                  enableQueue = "true";
                };
              };
            }
            {
              Readarr = {
                icon = "readarr.png";
                href = "http://${serverIp}:8787/";
                statusStyle = "dot";
                # ping = "192.168.188.117:8096";
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
                href = "http://${serverIp}:8989/";
                statusStyle = "dot";
                # ping = "192.168.188.117:8096";
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
                href = "http://${serverIp}:9696/";
                statusStyle = "dot";
                # ping = "192.168.188.117:8096";
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
                href = "http://${serverIp}:5055/";
                statusStyle = "dot";
                # ping = "192.168.188.117:8096";
                description = "Media Requests";
                widget = {
                  type = "jellyseerr";
                  url = "http://localhost:5055";
                  key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
                };
              };
            }
            {
              qBittorrent = {
                icon = "qbittorrent.png";
                href = "http://${serverIp}:8080/";
                statusStyle = "dot";
                # ping = "192.168.188.117:8096";
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
          "Media" = [
            {
              Immich = {
                icon = "immich.png";
                href = "http://${serverIp}:2283/";
                statusStyle = "dot";
                ping = "${serverIp}:2283";
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
                href = "http://${serverIp}:8096/";
                statusStyle = "dot";
                ping = "${serverIp}:8096";
                description = "Media Streaming";
                widget = {
                  type = "jellyfin";
                  url = "http://localhost:8096";
                  enableBlocks = true;
                  enableNowPlaying = true;
                  enableUser = true;
                  expandOneStreamToTwoRows = false;
                  key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
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
  };
}
