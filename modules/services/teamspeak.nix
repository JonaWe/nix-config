{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.teamspeak;
in {
  options.myconf.services.teamspeak = {
    enable = lib.mkEnableOption "Enable teamspeak service";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Opens ports for teamspeak";
    };
  };
  config = lib.mkIf cfg.enable {
    services.teamspeak3 = {
      enable = true;
      openFirewall = cfg.openFirewall;
    };
  };
}
