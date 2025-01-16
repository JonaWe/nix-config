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
  sops.secrets."syncthing/devices/homelab/key" = {
    owner = "jona";
    group = "users";
  };
  sops.secrets."syncthing/devices/homelab/cert" = {
    owner = "jona";
    group = "users";
  };
  sops.secrets."syncthing/devices/pangolin/id" = {
    owner = "jona";
    group = "users";
  };
  sops.templates."syncthing-user-password".content = ''${config.sops.placeholder."syncthing/user-password"}'';
  services = {
    syncthing = {
      enable = true;
      user = "jona";
      group = "users";
      dataDir = "/home/jona";
      configDir = "/home/jona/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      key = config.sops.secrets."syncthing/devices/homelab/key".path;
      cert = config.sops.secrets."syncthing/devices/homelab/cert".path;
      # settings.gui = {
      #   user = "jona";
      #   password = "$6$vcG1IuT4zuUQj/g3$A8qfB.0BN0Ue.0.PE7ZKIMolMJoQpTRrbXErVoQaGrJ7LWud9i3Fh3X4RlPOw2bsLJPkTNIKixCa9gepShnE4.";
      # password = config.sops.templates."syncthing-user-password".content;
      # password = "test";
      # };
      settings = import ./syncthing-settings.nix;
      #   devices = {
      #     pangolin = {
      #       id = "SCRTM6K-4YE5FGZ-HP27RDE-Z4PUUNQ-WUVCGF6-633QWR5-X6XYMPS-V72OFQ";
      #     };
      #     phone = {
      #       id = "NWDFWNP-J265KD5-TG6JSA6-5VWRPIN-PN3IBIW-2TUWQ2D-WCKAZ3Q-ZGQ7LAN";
      #     };
      #     homelab = {
      #       id = "DP6G2PA-QLRCJRJ-SZ644M2-LVX2T47-33KGVYT-2QJXS7N-JFXGNZ5-IIVC5Q5";
      #     };
      #   };
      #   folders = {
      #     "test-folder" = {
      #       id = "test-folder";
      #       label = "Test Folder";
      #       path = "/home/jona/test-folder";
      #       devices = ["pangolin" "phone" "homelab"];
      #     };
      #   };
      # };
    };
  };
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
