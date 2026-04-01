{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.wyoming-whisper = {
    containerFile = ./wyoming-whisper.container;

    user = "wyoming-whisper";
    group = "wyoming-whisper";

    zfsMounts = {
      "/opt/services/wyoming-whisper/config" = "zdata/enc/services/wyoming-whisper/config";
    };
  };
}
