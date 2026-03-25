{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.homelab;
in {
  options.homelab.services = mkOption {
    description = "Declarative Homelab Services";
    default = {};
    type = types.attrsOf (types.submodule {
      options = {
        port = mkOption {
          type = types.int;
          description = "Internal localhost port";
        };
        nginx = {
          enable = mkEnableOption "Enable Nginx for this service";
          domain = mkOption {
            type = types.str;
            description = "Subdomain for Nginx";
          };
          websockets = mkOption {
            type = types.bool;
            default = false;
            description = "Enable websockets for virtual host";
          };
          extraConfig = mkOption {
            type = types.str;
            default = '''';
            description = "Extra config for virtual host";
          };
        };
        containerFile = mkOption {
          type = types.path;
          description = "Path to the .container file";
        };
        user = mkOption {
          type = types.str;
          default = "root";
        };
        group = mkOption {
          type = types.str;
          default = "root";
        };

        zfsMounts = mkOption {
          type = types.attrsOf types.str;
          default = {};
        };
      };
    });
  };

  config = mkIf (cfg.services != {}) {
    virtualisation.podman.enable = true;

    environment.etc =
      mapAttrs' (
        name: svc:
          nameValuePair "containers/systemd/${name}.container" {source = svc.containerFile;}
      )
      cfg.services;

    services.nginx.virtualHosts =
      mapAttrs' (
        name: svc:
          nameValuePair svc.nginx.domain {
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString svc.port}";
              proxyWebsockets = svc.nginx.websockets;
              extraConfig = svc.nginx.extraConfig;
            };
          }
      )
      cfg.services;

    fileSystems = mkMerge (mapAttrsToList (
        name: svc:
          mapAttrs' (
            mountPoint: device:
              nameValuePair mountPoint {
                inherit device;
                fsType = "zfs";
                # options = ["zfsutil"];
              }
          )
          svc.zfsMounts
      )
      cfg.services);

    systemd.tmpfiles.rules = flatten (mapAttrsToList (
        name: svc:
          mapAttrsToList (
            mountPoint: device: "d ${mountPoint} 0775 ${svc.user} ${svc.group} -"
          )
          svc.zfsMounts
      )
      cfg.services);
  };
}
