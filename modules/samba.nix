{...}: {
  users.users.samba-data = {
    isSystemUser = true;
  };
  services.samba = {
    openFirewall = true;
    enable = true;
    settings = {
      global = {
        "server string" = "Nix Samba Share";
        "netbios name" = "smbnix";
        security = "user";
        "hosts allow" = "192.168.188. 127.0.0.1 localhost";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      winkelsheim = {
        path = "/data/samba/winkelsheim";
        "read only" = "no";
        browsable = "yes";
        writable = "yes";
        "guest ok" = "yes";
        "create mask" = 0644;
        "directory mask" = 0755;
        "force user" = "samba-data";
        comment = "public samba share";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
