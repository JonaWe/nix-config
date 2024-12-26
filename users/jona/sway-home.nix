{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home/programs/neovim
    ../../home/programs/tmux
    ../../home/programs/sway
    ../../home/programs/kitty
    ../../home/programs/zathura
    ../../home/programs/browser
    ../../home/programs/discord
    ./base-home.nix
  ];

  # services.gnome.gnome-keyring.enable = true;
  # services.dbus.enable = true;

  # services.gvfs.enable = true; # Mount, trash, and other functionalities
  # services.tumbler.enable = true; # Thumbnail support for images

  xdg.portal = {
      enable = true;
      # wlr.enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
  wayland.windowManager.sway = {
      enable = true;
      config = rec {
          modifier = "Mod4";
          terminal = "kitty"; 
          startup = [
          ];
      };
      extraOptions = [  "--unsupported-gpu"
      ];
      swaynag.enable = true;
      extraSessionCommands = ''
          export SDL_VIDEODRIVER=wayland
          export QT_QPA_PLATFORM=wayland
          export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
          export _JAVA_AWT_WM_NONREPARENTING=1
          export MOZ_ENABLE_WAYLAND=1
          '';
      wrapperFeatures.gtk = true;
  };
  # programs.sway = {
  #   enable = true;
  #
  #
  # };
  # services.greetd = {
  #   enable = true;
  #   systemdIntegration = {
  #     enable = true;
  #     extraVariables = ["DISPLAY" "HYPRLAND_INSTANCE_SIGNATURE"];
  #   };
  #   settings = rec {
  #     initial_session = {
  #       command = "${pkgs.sway}/bin/sway --unsupported-gpu";
  #       # command = "${pkgs.sway}/bin/sway --unsupported-gpu";
  #       user = "jona";
  #     };
  #     default_session = initial_session;
  #   };
  # };

  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.wayland = true;
}
