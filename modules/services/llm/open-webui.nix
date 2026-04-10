{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.open-webui = {
    containerFile = ./open-webui.container;

    user = "openwebui";
    group = "openwebui";

    port = 8014;

    nginx = {
      enable = true;
      domain = "llm.ts.pinkorca.de";
      websockets = true;
    };

    zfsMounts = {
      "/opt/services/open-webui/config" = "zdata/enc/services/open-webui/config";
    };
  };
}
