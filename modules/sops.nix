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

  sops.secrets."porkbun/api-key" = {};
  sops.secrets."porkbun/secret-api-key" = {};

  sops.templates."ddclient.conf" = {
    content = ''
      daemon=300
      use=web

      protocol=porkbun
      apikey=${config.sops.placeholder."porkbun/api-key"}
      secretapikey=${config.sops.placeholder."porkbun/secret-api-key"}
      home.pinkorca.de
    '';
  };

  services.ddclient = {
    enable = true;
    configFile = config.sops.templates."ddclient.conf".path;
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
