{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = "${builtins.toString inputs.mysecrets}/secrets.yaml";
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/root/.config/sops/age/keys.txt";

  environment.systemPackages = with pkgs; [
    sops
  ];
}
