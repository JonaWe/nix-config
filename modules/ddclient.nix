{config, ...}: {
  sops.secrets."porkbun/api-key" = {};
  sops.secrets."porkbun/secret-api-key" = {};

  sops.templates."ddclient.conf" = {
    content = ''
      daemon=600
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
}
