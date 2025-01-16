{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  # imports = [
  #   inputs.sops-nix.nixosModules.sops
  # ];
  #
  # sops.defaultSopsFile = "${builtins.toString inputs.mysecrets}/secrets.yaml";
  # sops.defaultSopsFormat = "yaml";
  #
  # sops.age.keyFile = "/home/jona/.config/sops/age/keys.txt";
  #
  # environment.systemPackages = with pkgs; [
  #   sops
  # ];
  sops.secrets."syncthing/user-password" = {
    owner = "jona";
    group = "users";
  };
  sops.secrets."syncthing/devices/pangolin/key" = {
    owner = "jona";
    group = "users";
  };
  sops.secrets."syncthing/devices/pangolin/cert" = {
    owner = "jona";
    group = "users";
  };
  sops.secrets."syncthing/devices/homelab/id" = {
    owner = "jona";
    group = "users";
  };
  sops.templates."syncthing-user-password".content = ''${config.sops.placeholder."syncthing/user-password"}'';
  sops.templates."syncthing-homelab-id".content = ''${config.sops.placeholder."syncthing/devices/homelab/id"}'';
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
      # settings.gui = {
      #   user = "jona";
      #   password = "$6$vcG1IuT4zuUQj/g3$A8qfB.0BN0Ue.0.PE7ZKIMolMJoQpTRrbXErVoQaGrJ7LWud9i3Fh3X4RlPOw2bsLJPkTNIKixCa9gepShnE4.";
        # password = config.sops.templates."syncthing-user-password".content;
        # password = "test";
      # };
      settings = {
        devices = {
            homelab = {
                id = config.sops.templates."syncthing-homelab-id".content;
            };
        };
        folders = {
          "test-folder" = {
            path = "/home/jona/test-folder";
            devices = [];
          };
        };
      };
    };
  };
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
