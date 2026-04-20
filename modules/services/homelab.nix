{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.homelab;
in {
  options.homelab.enable = mkEnableOption "Enable homelab service stack";

  options.homelab.services = mkOption {
    description = "Declarative Homelab Services";
    default = {};
    type = types.attrsOf (types.submodule {
      options = {
        port = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Internal localhost port";
        };
        openFirewall = mkOption {
          type = types.bool;
          default = false;
          description = "Open the firewall for the specified port";
        };
        containerFile = mkOption {type = types.path;};

        user = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        group = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
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

        snapshots = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable Sanoid snapshots for this service's ZFS datasets.";
          };
          template = mkOption {
            type = types.str;
            default = "default";
            description = "Sanoid template name used for this service's ZFS datasets.";
          };
        };
      };
    });
  };

  config = mkIf (cfg.enable && cfg.services != {}) {
    virtualisation.podman.enable = true;

    hardware.nvidia-container-toolkit.enable = true;

    networking.firewall.allowedTCPPorts = flatten (mapAttrsToList (
      name: svc:
        optional (svc.openFirewall && svc.port != null) svc.port
    ) cfg.services);

    users.users = mkMerge (mapAttrsToList (name: svc:
      optionalAttrs (svc.user != null) {
        ${svc.user} = {
          isNormalUser = true;
          # podman container locations
          home = "/var/lib/homes/${svc.user}";
          createHome = true;
          # required for podman to automatically start the containers
          linger = true;
        }
        // optionalAttrs (svc.group != null) {group = svc.group;}
        // optionalAttrs (svc.uid != null) {uid = svc.uid;};
      }
    ) cfg.services);

    users.groups = mkMerge (mapAttrsToList (name: svc:
      optionalAttrs (svc.group != null) {
        ${svc.group} = optionalAttrs (svc.gid != null) {gid = svc.gid;};
      }
    ) cfg.services);

    environment.etc =
      (mapAttrs' (
          name: svc:
            nameValuePair "containers/systemd/${name}.container" {source = svc.containerFile;}
        )
        cfg.services)
      // {
        # make nvidia container toolkit available
        "cdi/nvidia-container-toolkit.json".source = "/run/cdi/nvidia-container-toolkit.json";
      };

    services.nginx.virtualHosts = mkMerge (mapAttrsToList (
        name: svc:
          optionalAttrs svc.nginx.enable {
            ${svc.nginx.domain} = {
              useACMEHost = "pinkorca.de";
              forceSSL = true;
              http2 = true;
              locations."/" = {
                proxyWebsockets = svc.nginx.websockets;
                extraConfig = svc.nginx.extraConfig;
              } // optionalAttrs (svc.port != null) {
                proxyPass = "http://127.0.0.1:${toString svc.port}";
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

    services.sanoid.datasets = mkMerge (mapAttrsToList (
        name: svc:
          optionalAttrs svc.snapshots.enable (mapAttrs' (
              mountPoint: dataset:
                nameValuePair dataset {
                  useTemplate = [svc.snapshots.template];
                }
            )
            svc.zfsMounts)
      )
      cfg.services);

    systemd.services = mkMerge (flatten (mapAttrsToList (
        name: svc:
          mapAttrsToList (
            mountPoint: device: let
              cleanPath = replaceStrings ["/"] ["-"] (removePrefix "/" mountPoint);
              # fallback
              chownUser = if svc.user != null then svc.user else "root";
              chownGroup = if svc.group != null then svc.group else "root";
            in {
              "${name}-perms-${cleanPath}" = {
                description = "Set permissions for ${name} mount ${mountPoint}";
                wantedBy = ["multi-user.target"];

                unitConfig.RequiresMountsFor = [mountPoint];

                before = ["${name}.service"];
                requiredBy = ["${name}.service"];

                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                };

                script = ''
                  chown -R ${chownUser}:${chownGroup} ${mountPoint}
                  chmod -R 0775 ${mountPoint}
                '';
              };
            }
          )
          svc.zfsMounts
      )
      cfg.services));
  };
}
