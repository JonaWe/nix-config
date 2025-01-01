{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];
  nixpkgs.overlays = [inputs.nix-minecraft.overlay];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    package = pkgs.minecraft-server-1-12;
    servers = {
      test-server = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_4;
        serverProperties = {
          gamemode = "survival";
          difficulty = "hard";
          simulation-distance = 10;
        };
        symlinks = {
          "mods" = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
            fabric-api = fetchurl {url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5tj7y3PJ/fabric-api-0.114.0%2B1.21.4.jar";};
          });
        };
      };
    };
  };
}
