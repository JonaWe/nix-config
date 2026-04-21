{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.stirling-pdf = {
    containerFile = ./stirling-pdf.container;

    user = "stirling-pdf";
    group = "stirling-pdf";

    port = 8314;

    nginx = {
      enable = true;
      domain = "pdf.ts.pinkorca.de";
    };

    zfsMounts = {
      "/opt/services/stirling-pdf/config" = {
        dataset = "zdata/enc/services/stirling-pdf/config";
        snapshot = true;
        backup = true;
      };
    };
  };
}
