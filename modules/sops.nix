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

  systemd.services."sometestservice" = {
    path = [
      pkgs.curl
    ];
    script = ''
      echo "
      Hey bro! I'm a service, and imma send this secure password:
      $(cat ${config.sops.secrets."duckdns/token".path})
      located in:
      ${config.sops.secrets."duckdns/token".path}
      to database and hack the mainframe
      " > /var/lib/duckdns/testfile
    '';
    startAt = "hourly";
    serviceConfig = {
      User = "duckdns";
      WorkingDirectory = "/var/lib/duckdns";
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
