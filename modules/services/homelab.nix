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
        containerFile = mkOption {type = types.path;};

        user = mkOption {type = types.str;};
        group = mkOption {type = types.str;};
        uid = mkOption {
          type = types.nullOr types.int;
          default = null;
        };
        gid = mkOption {
          type = types.nullOr types.int;
          default = null;
        };

        nginx = {
          enable = mkEnableOption "Enable Nginx for this service";
          domain = mkOption {
            type = types.str;
            default = "";
          };
          websockets = mkOption {
            type = types.bool;
            default = false;
          };
          extraConfig = mkOption {
            type = types.str;
            default = "";
          };
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

    users.users = mkMerge (mapAttrsToList (name: svc: {
        ${svc.user} =
          {
            isNormalUser = true;
            group = svc.group;
            home = "/var/lib/${svc.user}";
            createHome = true;
            # required for podman to automatically start the containers
            linger = true;
          }
          // optionalAttrs (svc.uid != null) {uid = svc.uid;};
      })
      cfg.services);

    users.groups = mkMerge (mapAttrsToList (name: svc: {
        ${svc.group} = optionalAttrs (svc.gid != null) {gid = svc.gid;};
      })
      cfg.services);

    environment.etc =
      mapAttrs' (
        name: svc:
          nameValuePair "containers/systemd/${name}.container" {source = svc.containerFile;}
      )
      cfg.services;

    services.nginx.virtualHosts = mkMerge (mapAttrsToList (
        name: svc:
          optionalAttrs svc.nginx.enable {
            ${svc.nginx.domain} = {
              useACMEHost = "pinkorca.de";
              forceSSL = true;
              http2 = true;
              locations."/" = {
                proxyPass = "http://127.0.0.1:${toString svc.port}";
                proxyWebsockets = svc.nginx.websockets;
                extraConfig = svc.nginx.extraConfig;
              };
            };
          }
      )
      cfg.services);

    fileSystems = mkMerge (mapAttrsToList (
        name: svc:
          mapAttrs' (
            mountPoint: device:
              nameValuePair mountPoint {
                inherit device;
                fsType = "zfs";
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
