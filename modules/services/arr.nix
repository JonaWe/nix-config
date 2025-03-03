{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myconf.services.arr;
in {
  options.myconf.services.arr = {
    enable = lib.mkEnableOption "Enable *arr";
  };

  config = lib.mkIf cfg.enable {
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "ens3";
      # Lazy IPv6 connectivity for the container
      # enableIPv6 = true;
    };

    containers.arr = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.188.117";
      localAddress = "192.168.1.1";
      # hostAddress6 = "fc00::1";
      # localAddress6 = "fc00::2";
      config = {
        config,
        pkgs,
        lib,
        ...
      }: {
        services.transmission.enable = true;

        # services.nextcloud = {
        #   enable = true;
        #   package = pkgs.nextcloud28;
        #   hostName = "localhost";
        #   config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}"; # DON'T DO THIS IN PRODUCTION - the password file will be world-readable in the Nix Store!
        # };

        system.stateVersion = "24.11";

        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [80];
          };
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;
      };
    };
  };
}
