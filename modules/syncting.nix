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
  services = {
    syncthing = {
      enable = true;
      user = "jona";
      dataDir = "/home/jona";
      configDir = "/home/jona/.config/syncthing";
    };
  };
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
}
