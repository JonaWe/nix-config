{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.ollama = {
    containerFile = ./ollama.container;
    rootless = true;

    user = "ollama";
    group = "ollama";

    zfsMounts = {
      "/opt/services/ollama/config" = {
        dataset = "zdata/enc/services/ollama/config";
        snapshot = true;
        backup = false;
      };
    };
  };
}
