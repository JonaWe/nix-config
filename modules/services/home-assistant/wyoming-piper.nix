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
      "/opt/services/wyoming-piper/config" = {
        dataset = "zdata/enc/services/wyoming-piper/config";
        snapshot = true;
        backup = false;
      };
    };
  };
}
