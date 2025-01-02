{...}: {
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
