{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kitty
    uwsm
    greetd.tuigreet
    hyprpolkitagent
    hyprland
    hyprpaper
    hyprsunset
    hyprshot
    swaynotificationcenter
    playerctl
    brightnessctl
    ghostty
    yazi
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  programs.waybar.enable = true;
  # programs.waybar.systemd.target = "grapical.target";

  # electron applications defaulting to Wayland rather than X11
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.gnome.gnome-keyring.enable = true;

  security.polkit.enable = true;
  programs.uwsm.enable = true;

  services.dbus.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  # services.devmon.enable = true;
  services.tumbler.enable = true;

  programs.dconf.enable = true;
  # programs.sway.enable = true;

  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet \
  #         --time --time-format '%I:%M %p | %a • %h | %F' \
  #         --cmd 'uwsm start hyprland'";
  #       user = "greeter";
  #     };
  #   };
  # };
  #
  users.users.greeter = {
    isNormalUser = false;
    description = "greetd greeter user";
    extraGroups = ["video" "audio"];
    linger = true;
  };

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "uwsm start -S -F /run/current-system/sw/bin/Hyprland";
        user = "jona";
      };
      # default_session = initial_session;
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time --time-format '%I:%M %p | %a • %h | %F' \
          --cmd 'uwsm start hyprland'";
        user = "greeter";
      };
    };
  };
}
