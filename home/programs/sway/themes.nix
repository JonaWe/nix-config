{
  config,
  pkgs,
  ...
}: {
  home.pointerCursor = {
    name = "Banana";
    # name = "Posy_Cursor";
    size = 32;
    package = pkgs.banana-cursors;
    # package = pkgs.posy-cursors;
    x11.enable = true;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    theme.package = pkgs.gnome-themes-extra;
    iconTheme.package = pkgs.adwaita-icon-theme;
    iconTheme.name = "Adwaita";
    cursorTheme.name = config.home.pointerCursor.name;
    cursorTheme.size = config.home.pointerCursor.size;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  qt = {
    enable = true;
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };
}
