{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  sops.secrets."syncthing/devices/pangolin/key" = {
    owner = "jona";
    group = "users";
  };
  sops.secrets."syncthing/devices/pangolin/cert" = {
    owner = "jona";
    group = "users";
  };
  services = {
    syncthing = {
      enable = true;
      user = "jona";
      group = "users";
      dataDir = "/home/jona";
      configDir = "/home/jona/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      key = config.sops.secrets."syncthing/devices/pangolin/key".path;
      cert = config.sops.secrets."syncthing/devices/pangolin/cert".path;
      # settings.gui.insecureSkipHostcheck = true;
      settings = import ./syncthing-settings.nix {
        base-dir = "/home/jona/";
        device-name = "pangolin";
      };
    };
  };
}
