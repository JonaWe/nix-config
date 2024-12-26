{pkgs, ...}: {
  home.file.".config/discord/settings.json".source = ./settings.json;
  home.packages = with pkgs; [
    vencord
    # (discord.override {
    #   # withOpenASAR = true; # can do this here too
    #   withVencord = true;
    # })
  ];
}
