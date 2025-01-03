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

  sops.secrets.example_key = {};
  # sops.secrets."myservice/my_subdir/my_secret" = {
  #   owner = "sometestservice";
  # };
  #
  # systemd.services."sometestservice" = {
  #   script = ''
  #     echo "
  #     Hey bro! I'm a service, and imma send this secure password:
  #     $(cat ${config.sops.secrets."myservice/my_subdir/my_secret".path})
  #     located in:
  #     ${config.sops.secrets."myservice/my_subdir/my_secret".path}
  #     to database and hack the mainframe
  #     " > /var/lib/sometestservice/testfile
  #   '';
  #   serviceConfig = {
  #     User = "sometestservice";
  #     WorkingDirectory = "/var/lib/sometestservice";
  #   };
  # };
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
