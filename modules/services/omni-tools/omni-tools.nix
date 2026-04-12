{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.omni-tools = {
    containerFile = ./omni-tools.container;

    user = "omni-tools";
    group = "omni-tools";

    port = 8315;

    nginx = {
      enable = true;
      domain = "tools.ts.pinkorca.de";
    };
  };
}
