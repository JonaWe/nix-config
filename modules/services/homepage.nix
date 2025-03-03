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
      services = [
        {
          "Media" = [
            {
              Immich = {
                icon = "immich.png";
                href = "http://192.168.188.117:2283/";
                statusStyle = "dot";
                ping = "192.168.188.117:2283";
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
                href = "http://192.168.188.117:8096/";
                statusStyle = "dot";
                ping = "192.168.188.117:8096";
                description = "Media streaming service";
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
        # {
        #   "System" = [
        #   ];
        # }
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
