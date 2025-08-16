{
  config,
  pkgs,
  ...
}:
# let
#   lowBatteryNotifier =
#     pkgs.writeScript "lowBatteryNotifier"
#     ''
#       BAT_PCT=`${pkgs.acpi}/bin/acpi -b | ${pkgs.gnugrep}/bin/grep -P -o '[0-9]+(?=%)'`
#       BAT_STA=`${pkgs.acpi}/bin/acpi -b | ${pkgs.gnugrep}/bin/grep -P -o '\w+(?=,)'`
#       echo "`date` battery status:$BAT_STA percentage:$BAT_PCT"
#       test $BAT_PCT -le 10 && test $BAT_PCT -gt 5 && test $BAT_STA = "Discharging" && DISPLAY=:0.0 ${pkgs.libnotify}/bin/notify-send -c device -u normal   "Low Battery" "Would be wise to keep my charger nearby."
#       test $BAT_PCT -le  5                        && test $BAT_STA = "Discharging" && DISPLAY=:0.0 ${pkgs.libnotify}/bin/notify-send -c device -u critical "Low Battery" "Charge me or watch me die!"
#     '';
# in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/ssh.nix
    ../../modules/docker.nix
    ../../modules/fonts.nix
    # ../../modules/sway.nix
    ../../modules/hyprland.nix
    ../../modules/steam.nix
    ../../modules/bluetooth.nix
    ../../modules/powermanagement.nix
    ../../modules/sops.nix
    ../../modules/wireguard-client.nix
  ];

  # services.cron = {
  #   enable = true;
  #   systemCronJobs = let
  #     userName = "jona";
  #   in [
  #     "* * * * * ${userName} bash -x ${lowBatteryNotifier} > /tmp/cron.batt.log 2>&1"
  #   ];
  # };

  boot.supportedFilesystems = ["ntfs"];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.videoDrivers = ["amdgpu"];

  myconf.disk = {
    enable = true;
    rootPool = {
      enable = true;
      encrypted = true;
      # drive = "/dev/disk/by-id/nvme-eui.ace42e0035e9a7b32ee4ac0000000001";
      drive = "/dev/disk/by-id/nvme-SKHynix_HFS002TEJ9X162N_ASCAN41151140A92T";
    };
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  myconf.services = {
    tailscale = {
      enable = true;
    };
    syncthing = {
      enable = true;
      dataDir = "/home/jona";
      user = "jona";
      group = "users";
    };
  };

  services.gnome = {
    evolution-data-server.enable = true;
    gnome-online-accounts.enable = true;
    gnome-keyring.enable = true;
  };

  networking.hosts = {
    "192.168.188.133" = ["home.lab"];
  };

  networking.hostName = "pangolin";

  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  nixpkgs.config.rocmSupport = true;

  # TODO: what is this?
  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];

  environment.systemPackages = with pkgs; [
    cifs-utils
    dnsutils
    # libnotify
    # # lowBatteryNotifier
    # acpi
    # gnugrep
    # libnotify
  ];

  fileSystems."/run/media/jona/jona" = {
    device = "//100.64.0.2/jona";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";
      # in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
    in ["${automount_opts},uid=1000,gid=100"];
  };

  fileSystems."/run/media/jona/games" = {
    device = "//100.64.0.2/games";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      # TODO: replace uid and gid with variables
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users,uid=1000,gid=100";
      # in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
    in ["${automount_opts},uid=1000,gid=100"];
  };

  fileSystems."/run/media/jona/winkelsheim" = {
    device = "//100.64.0.2/winkelsheim";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      # TODO: replace uid and gid with variables
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users,uid=1000,gid=100";
      # in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
    in ["${automount_opts},uid=1000,gid=100"];
  };

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        devices = [
          "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
        ];
        extraDefCfg = "process-unmapped-keys yes";
        # tap-time 150
        # hold-time 200
        # a (tap-hold $tap-time $hold-time a lmet)
        # s (tap-hold $tap-time $hold-time s lalt)
        # d (tap-hold $tap-time $hold-time d lsft)
        # f (tap-hold $tap-time $hold-time f lctl)
        # j (tap-hold $tap-time $hold-time j rctl)
        # k (tap-hold $tap-time $hold-time k rsft)
        # l (tap-hold $tap-time $hold-time l ralt)
        # ; (tap-hold $tap-time $hold-time ; rmet)
        config = ''
          (defsrc
          a s d f j k l ;
          )

          (deftemplate homerowmod (timeout char mod)
            (switch
              ((key-timing 3 less-than 200)) $char break
              () (tap-hold-release 0 $timeout $char $mod) break
            )
          )

          (deflayermap (main)
            caps (tap-hold 250 250 esc esc)
            a (t! homerowmod 250 a lalt)
            s (t! homerowmod 250 s lmet)
            d (t! homerowmod 200 d lsft)
            f (t! homerowmod 250 f lctl)
            j (t! homerowmod 250 j rctl)
            k (t! homerowmod 200 k rsft)
            l (t! homerowmod 250 l rmet)
            ; (t! homerowmod 250 ; ralt)
          )
        '';
        # config = ''
        #   (defsrc
        #    caps a s d f j k l ;
        #   )
        #   (defvar
        #    tap-time 200
        #    hold-time 200
        #   )
        #   (defalias
        #    caps (tap-hold $tap-time $hold-time esc lctl)
        #    a (tap-hold $tap-time $hold-time a lalt)
        #    s (tap-hold $tap-time $hold-time s lmet)
        #    d (tap-hold $tap-time $hold-time d lsft)
        #    f (tap-hold $tap-time $hold-time f lctl)
        #    j (tap-hold $tap-time $hold-time j rctl)
        #    k (tap-hold $tap-time $hold-time k rsft)
        #    l (tap-hold $tap-time $hold-time l rmet)
        #    ; (tap-hold $tap-time $hold-time ; ralt)
        #   )
        #
        #   (deflayer base
        #    @caps @a  @s  @d  @f  @j  @k  @l  @;
        #   )
        # '';
      };
    };
  };

  system.stateVersion = "24.11";
}
