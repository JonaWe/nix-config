{...}: {
  services.samba = {
    openFirewall = true;
    enable = true;
    settings = {
      global = {
        "server string" = "Nix Samba Share";
        "netbios name" = "smbnix";
        security = "user";
        "hosts allow" = "192.168.188. 127.0.0.1 localhost";
        # this seems to be an unknown parameter
        # "host deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      public = {
        path = "/mnt/media";
        "read only" = "no";
        browsable = "yes";
        "guest ok" = "yes";
        comment = "public samba share";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
