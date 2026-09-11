{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.homelab;

  # Services whose quadlet lives in /etc/containers/systemd and runs under the
  # system manager with User=, vs. those that run as a genuine user unit.
  systemServices = filterAttrs (_: svc: !svc.rootless) cfg.services;
  rootlessServices = filterAttrs (_: svc: svc.rootless && svc.user != null) cfg.services;

  environmentFilesDropIn = svc: ''
    [Container]
    ${concatMapStringsSep "\n" (envFile: "EnvironmentFile=${toString envFile}") svc.environmentFiles}
  '';

  startTimeoutDropIn = svc: ''
    [Service]
    TimeoutStartSec=${toString svc.startTimeout}
  '';

  # Quadlet directory inside a service user's home. The user's systemd
  # instance picks these up on daemon-reload, i.e. at the latest on boot.
  quadletDir = svc: "/var/lib/homes/${svc.user}/.config/containers/systemd";
in {
  options.homelab.enable = mkEnableOption "Enable homelab service stack";

  options.homelab.autoUpdate = {
    enable = mkEnableOption ''
      podman-auto-update for containers labelled AutoUpdate=registry.

      The label is the opt-in: only containers carrying it are touched, and on
      a pinned tag it does nothing because the digest never moves. Rollback is
      on by default, but only bites if the unit actually fails to start — see
      Notify=healthy in the container files.
    '';

    schedule = mkOption {
      type = types.str;
      default = "04:00";
      description = "systemd calendar expression for the per-user auto-update timer";
    };
  };

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

        rootless = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Place the quadlet in the service user's own systemd instance
            (~/.config/containers/systemd) instead of the system-wide
            /etc/containers/systemd, so podman gets /run/user/<uid> as its
            runroot and a user manager to register healthcheck timers with.

            The container file must drop User=/Group= and use
            WantedBy=default.target for this to work.
          '';
        };

        startTimeout = mkOption {
          type = types.int;
          default = 1800;
          description = ''
            Seconds a rootless service may take to start, as a quadlet
            drop-in. Generous because the start includes the image pull.
            Lower it for a service that should fail fast.
          '';
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

    # podman ships this unit, so NixOS emits a drop-in rather than replacing it.
    systemd.user.timers.podman-auto-update = mkIf cfg.autoUpdate.enable {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.autoUpdate.schedule;
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };

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

    environment.etc = mkMerge [
      (mapAttrs' (
          name: svc:
            nameValuePair "containers/systemd/${name}.container" {source = svc.containerFile;}
        )
        systemServices)

      (mkMerge (mapAttrsToList (
          name: svc:
            optionalAttrs (svc.environmentFiles != []) {
              "containers/systemd/${name}.container.d/10-environment-files.conf" = {
                text = environmentFilesDropIn svc;
              };
            }
        )
        systemServices))

      {
        # make nvidia container toolkit available
        "cdi/nvidia-container-toolkit.json".source = "/run/cdi/nvidia-container-toolkit.json";
      }
    ];

    # Rootless services get their quadlet linked into the user's own config
    # directory instead. L+ replaces whatever is there, so a changed store path
    # takes effect on the next activation.
    systemd.tmpfiles.rules = flatten (mapAttrsToList (
        name: svc: let
          dir = quadletDir svc;
          owner = "${svc.user} ${
            if svc.group != null
            then svc.group
            else svc.user
          }";
        in
          [
            "d /var/lib/homes/${svc.user}/.config 0755 ${owner} -"
            "d /var/lib/homes/${svc.user}/.config/containers 0755 ${owner} -"
            "d ${dir} 0755 ${owner} -"
            "L+ ${dir}/${name}.container - - - - ${svc.containerFile}"
            "d ${dir}/${name}.container.d 0755 ${owner} -"
            # tmpfiles cannot carry multi-line content, so link a store file.
            "L+ ${dir}/${name}.container.d/10-start-timeout.conf - - - - ${
              pkgs.writeText "${name}-start-timeout.conf" (startTimeoutDropIn svc)
            }"
          ]
          ++ optionals (svc.environmentFiles != []) [
            "L+ ${dir}/${name}.container.d/10-environment-files.conf - - - - ${
              pkgs.writeText "${name}-environment-files.conf" (environmentFilesDropIn svc)
            }"
          ]
      )
      rootlessServices);

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

                # A rootless service has no system unit to order against;
                # quadlet emits RequiresMountsFor into the user unit itself.
                before = optional (!svc.rootless) "${name}.service";
                requiredBy = optional (!svc.rootless) "${name}.service";

                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                };

                # Not recursive: a fresh dataset mounts as root:root, and the
                # container owns everything it creates below. Repair a tree by
                # hand if one ever needs it.
                script = ''
                  chown ${chownUser}:${chownGroup} ${mountPoint}
                  chmod 0775 ${mountPoint}
                '';
              };
            }
          )
          svc.zfsMounts
      )
      cfg.services));
  };
}
