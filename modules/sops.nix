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

  sops.age.keyFile = "/home/jona/.config/sops/age/keys.txt";

  # sops.secrets."duckdns/token" = {
  #   # owner = "duckdns";
  # };

  services.ddclient = {
    enable = true;
    configFile = builtins.toFile "ddclient.conf" ''
      daemon=300
      use=web
      protocol=porkbun
      home.pinkorca.de
    '';
# apikey_env=${sops}
# secretapikey_env=${}
  };

  # users.users.duckdns = {
  #   isSystemUser = true;
  #   group = "duckdns";
  # };
  # users.groups.duckdns = {};
  #
  # systemd.services."duckdns-updater" = {
  #   path = [
  #     pkgs.curl
  #   ];
  #   script = ''
  #     curl "https://www.duckdns.org/update?domains=jonawe&token=$(cat ${config.sops.secrets."duckdns/token".path})&ip="
  #   '';
  #   startAt = "hourly";
  #   serviceConfig = {
  #     User = "duckdns";
  #   };
  # };

  environment.systemPackages = with pkgs; [
    sops
  ];
}
