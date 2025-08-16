{...}: {
  # programs.steam = {
  #   enable = true;
  #   localNetworkGameTransfers.openFirewall = true;
  # };
  programs = {
    gamemode.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
    };
  };
}
