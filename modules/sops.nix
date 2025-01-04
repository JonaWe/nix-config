{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = "${builtins.toString inputs.mysecrets}/secrets.yaml";
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/jona/.config/sops/age/keys.txt";

  sops.secrets."duckdns/token" = {
    owner = "duckdns";
  };

  users.users.duckdns = {
    isSystemUser = true;
    group = "duckdns";
  };
  users.groups.duckdns = {};

  systemd.services."duckdns-updater" = {
    path = [
      pkgs.curl
    ];
    script = ''
      echo "https://www.duckdns.org/update?domains=jonawe&token=$(cat ${config.sops.secrets."duckdns/token".path})&ip="
    '';
    startAt = "hourly";
    serviceConfig = {
      User = "duckdns";
    };
  };

  # sops.secrets.example_key = {};
  # sops.secrets."myservice/my_subdir/my_secret" = {
  #   owner = "sometestservice";
  # };
  #
  #
  # users.users.sometestservice = {
  #   home = "/var/lib/sometestservice";
  #   createHome = true;
  #   isSystemUser = true;
  #   group = "sometestservice";
  # };
  # users.groups.sometestservice = {};

  environment.systemPackages = with pkgs; [
    sops
  ];
}
