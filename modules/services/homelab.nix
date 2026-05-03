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
        environmentFiles = mkOption {
          type = types.listOf types.path;
          default = [];
          description = "Environment files passed to the service's Quadlet [Container] section.";
        };

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
          default = {};
          description = "Mapping of mountpoints to ZFS datasets with snapshot and backup policies.";
          type = types.attrsOf (types.submodule {
            options = {
              dataset = mkOption {
                type = types.str;
                description = "The raw ZFS dataset name (e.g., zdata/enc/services/app).";
              };
              snapshot = mkOption {
                type = types.bool;
                description = "Enable or disable Sanoid snapshots for this dataset.";
              };
              backup = mkOption {
                type = types.bool;
                description = "Include or exclude this dataset from the Restic backup.";
              };
            };
          });
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
      )
      cfg.services);

    users.users = mkMerge (mapAttrsToList (
        name: svc:
          optionalAttrs (svc.user != null) {
            ${svc.user} =
              {
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
      )
      cfg.services);

    users.groups = mkMerge (mapAttrsToList (
        name: svc:
          optionalAttrs (svc.group != null) {
            ${svc.group} = optionalAttrs (svc.gid != null) {gid = svc.gid;};
          }
      )
      cfg.services);

    environment.etc =
      (mapAttrs' (
          name: svc:
            nameValuePair "containers/systemd/${name}.container" {source = svc.containerFile;}
        )
        cfg.services)
      // (mkMerge (mapAttrsToList (
          name: svc:
            optionalAttrs (svc.environmentFiles != []) {
              "containers/systemd/${name}.container.d/10-environment-files.conf" = {
                text = ''
                  [Container]
                  ${concatMapStringsSep "\n" (envFile: "EnvironmentFile=${toString envFile}") svc.environmentFiles}
                '';
              };
            }
        )
        cfg.services))
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
              locations."/" =
                {
                  proxyWebsockets = svc.nginx.websockets;
                  extraConfig = svc.nginx.extraConfig;
                }
                // optionalAttrs (svc.port != null) {
                  proxyPass = "http://127.0.0.1:${toString svc.port}";
                };
            };
          }
      )
      cfg.services);

    fileSystems = mkMerge (mapAttrsToList (
        name: svc:
          mapAttrs' (
            mountPoint: mountOpts:
              nameValuePair mountPoint {
                device = mountOpts.dataset;
                fsType = "zfs";
              }
          )
          svc.zfsMounts
      )
      cfg.services);

    services.sanoid.datasets = mkMerge (mapAttrsToList (
        name: svc:
          optionalAttrs svc.snapshots.enable (
            let
              snapMounts = filterAttrs (mp: opts: opts.snapshot) svc.zfsMounts;
            in
              mapAttrs' (
                mountPoint: mountOpts:
                  nameValuePair mountOpts.dataset {
                    useTemplate = [svc.snapshots.template];
                  }
              )
              snapMounts
          )
      )
      cfg.services);

    systemd.services = mkMerge (flatten (mapAttrsToList (
        name: svc:
          mapAttrsToList (
            mountPoint: mountOpts: let
              cleanPath = replaceStrings ["/"] ["-"] (removePrefix "/" mountPoint);
              chownUser =
                if svc.user != null
                then svc.user
                else "root";
              chownGroup =
                if svc.group != null
                then svc.group
                else "root";
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
