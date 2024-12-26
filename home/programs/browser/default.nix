{pkgs, ...}: {
  # home.file.".config/kitty/kitty.conf".source = ./kitty.conf;
  # home.packages = with pkgs; [floorp firefox];
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
    ];
  };
}
