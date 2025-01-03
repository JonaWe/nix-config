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
    servers = {
      test-server = {
        openFirewall = true;
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_4;
        serverProperties = {
          gamemode = "survival";
          difficulty = "hard";
          simulation-distance = 10;
        };
        symlinks = {
          "mods" = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
            fabric-api = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5tj7y3PJ/fabric-api-0.114.0%2B1.21.4.jar";
              hash = "sha256-TATNEpMOzG19eCI5NDhdYonSpkRLzH3q9T49o3kgHC0=";
            };
            sodium = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/AANobbMI/versions/tu8qILqH/sodium-fabric-0.6.6%2Bmc1.21.4.jar";
              hash = "sha256-Lt0Dw1YwlFQ9Pz1rlBB+D1hFtoL4QXKO5/jNXVwPjoM=";
            };
            simple-voice-chat = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/pl9FpaYJ/voicechat-fabric-1.21.4-2.5.26.jar";
              hash = "sha256-2ni2tQjMCO3jaEA1OHXoonZpGqHGVlY/9rzVsijrxVA=";
            };
          });
        };
      };
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 24454 ];
  };
}
