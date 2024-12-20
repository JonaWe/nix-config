{pkgs, ...}: {
  home.file.".config/sway" = {
    source = ./sway;
    recursive = true;
    executable = true;
  };
  home.file.".config/xkb" = {
    source = ./xkb;
    recursive = true;
  };
  home.file.".config/waybar" = {
    source = ./waybar;
    recursive = true;
  };
  home.file.".config/rofi" = {
    source = ./rofi;
    recursive = true;
  };
  programs.waybar.enable = true;
  home.packages = with pkgs; [
    rofi-wayland
    pcmanfm
      sway
  ];
  # programs.sway = {
  #   enable = true;
  # };
  # enable Sway window manager
  programs.sway = {
    enable = true;
    # systemd.enable = true;
  #   wrapperFeatures.gtk = true;
  #   extraPackages = with pkgs; [
  #     mako
  #     kitty
  #     foot
  #     wayland
  #     xdg-utils
  #     glib
  #     grim
  #     slurp
  #     wl-clipboard
  #   ];
  #
  #   extraSessionCommands = ''
  #     export SDL_VIDEODRIVER=wayland
  #     export QT_QPA_PLATFORM=wayland
  #     export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
  #     export _JAVA_AWT_WM_NONREPARENTING=1
  #     export MOZ_ENABLE_WAYLAND=1
  #   '';
  # };
}
