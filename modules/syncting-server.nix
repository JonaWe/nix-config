{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  sops.secrets."syncthing/devices/homelab/key" = {
    owner = "jona";
    group = "users";
  };
  sops.secrets."syncthing/devices/homelab/cert" = {
    owner = "jona";
    group = "users";
  };
  services = {
    syncthing = {
      enable = true;
      user = "jona";
      group = "users";
      dataDir = "/data/syncthing";
      configDir = "/data/syncthing/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      key = config.sops.secrets."syncthing/devices/homelab/key".path;
      cert = config.sops.secrets."syncthing/devices/homelab/cert".path;
      settings = import ./syncthing-settings.nix {base-dir = "/data/syncthing";};
    };
  };
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

  systemd.tmpfiles.rules = [
    "d /data/syncthing 0700 jona users -"
  ];
}
