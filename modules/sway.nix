{pkgs, ...}: let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-enviroment";
    executable = true;

    text = ''
      systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
      dbus-update-activation-enviroment
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-gtk
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-gtk
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure/-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsetting-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'WhiteSur-dark'
      gsettings set $gnome_schema cursor-theme 'capitaine-cursors-white'
    '';
  };
in {
  environment.systemPackages = [
    dbus-sway-environment
    configure-gtk
  ];

  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
  # services.dbus.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;

  programs.dconf.enable = true;
  programs.sway.enable = true;
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.sway}/bin/sway --unsupported-gpu";
        user = "jona";
      };
      default_session = initial_session;
    };
  };
}
