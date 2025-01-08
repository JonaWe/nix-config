{config, ...}: {
  networking.firewall.allowedTCPPorts = [80 443];
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."_" = {
      useACMEHost = "pinkorca.de";
      addSSL = true;
      # forceSSL = true;
      default = true;
      locations."/" = {
        proxyPass = "http://localhost:8096";
      };
    };
  };

  users.users.nginx.extraGroups = ["acme"];
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "dev@pinkorca.de";
      dnsProvider = "porkbun";
      reloadServices = ["nginx"];
      credentialFiles = {
        "PORKBUN_API_KEY_FILE" = config.sops.secrets."porkbun/api-key".path;
        "PORKBUN_SECRET_API_KEY_FILE" = config.sops.secrets."porkbun/secret-api-key".path;
      };
    };
    certs."pinkorca.de".extraDomainNames = [
      "*.pinkorca.de"
      "*.home.pinkorca.de"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /certs/acme 0750 acme acme -"
    # "Z /certs/acme 0750 acme acme - -"
    "L+ /var/lib/acme - - - - /certs/acme"
  ];
}
