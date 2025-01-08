{
  config,
  pkgs,
  ...
}: {
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
      default = true;
      locations."/" = {
        root = pkgs.writeTextDir "index.html" ''
          <!DOCTYPE html>
          <html lang="en">
          <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>home.pinkorca.de</title>
              <style>
                  body {
                      display: flex;
                      justify-content: center;
                      align-items: center;
                      height: 100vh;
                      margin: 0;
                      background-color: black;
                      color: white;
                      font-size: 2em;
                  }
              </style>
          </head>
          <body>
              Hello!
          </body>
          </html>
        '';
        index = "index.html";
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
