{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];
  nixpkgs.overlays = [inputs.nix-minecraft.overlay];

  services.minecraft-server = {
    enable = true;
    eula = true;
    servers = {
      test-server = {
        enable = true;
        package = pkgs.vanillaServers.vanilla-1_21_4;
        serverProperties = {
          gamemode = "survival";
          difficulty = "hard";
          simulation-distance = 10;
        };
      };
    };
  };
}
