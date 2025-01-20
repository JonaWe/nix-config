{pkgs, ...}: {
  # home.packages = with pkgs; [floorp firefox];
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--enable-features=TouchpadOverscrollHistoryNavigation"
    ];
  };
}
