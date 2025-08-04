{pkgs, ...}: {
  environment.systemPackages = [
    # configure-gtk
    pkgs.kitty
    pkgs.uwsm
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Electron applications defaulting to X11 rather than Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.gnome.gnome-keyring.enable = true;

  security.polkit.enable = true;

  # services.dbus.enable = true;
  # services.gvfs.enable = true;
  # services.udisks2.enable = true;
  # services.devmon.enable = true;
  # services.tumbler.enable = true;

  # programs.dconf.enable = true;
  # programs.sway.enable = true;

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.uwsm}/bin/uwsm start hyprland";
        user = "jona";
      };
      default_session = initial_session;
    };
  };
}
