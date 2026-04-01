{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.wyoming-piper = {
    containerFile = ./wyoming-piper.container;

    user = "wyoming-piper";
    group = "wyoming-piper";

    zfsMounts = {
      "/opt/services/wyoming-piper/config" = "zdata/enc/services/wyoming-piper/config";
    };
  };
}
