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
          motd = "§kMinecraft Nix Test Server";
          level-name = "world";
          gamemode = "survival";
          difficulty = "hard";
          view-distance = 10;
          max-players = 666;
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
            voicechat = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/4Zzq92HE/voicechat-fabric-1.21.4-2.5.27.jar";
              hash = "sha256-k6JIRkQybRFLW5VzfxMXPrGTu2NBTKji6+wc2v0p50g=";
            };
            armorstands = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/FlC9CXUY/versions/ywyjeMrW/armorstands-2.0.1%2B1.21.2.jar";
              hash = "sha256-uFEhb+h+SvNTOxh57+7rpHaicw/hxRmA+P5yttnA5qY=";
            };
            fabric-language-kotlin = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/csX9r2wS/fabric-language-kotlin-1.13.0%2Bkotlin.2.1.0.jar";
              hash = "sha256-in9nOy4TFb8svDzIaXU+III8Q/mqW+WW0PdNw8YmrZI=";
            };
            ledger = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/LVN9ygNV/versions/a6TcvEKA/ledger-1.3.7.jar";
              hash = "sha256-EGfHgYa5ejJ4BDxR0DPAeFHkV35fqoBnusUqF6vV0KA=";
            };
            lithium = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/t1FlWYl9/lithium-fabric-0.14.3%2Bmc1.21.4.jar";
              hash = "sha256-LJFVhw/3MnsPnYTHVZbM3xJtne1lV5twuYeqZSMZEn4=";
            };
            vanish = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/UL4bJFDY/versions/v24ijRym/vanish-1.5.9%2B1.21.4.jar";
              hash = "sha256-n0IkFzPjm+xprC0LzmejGiyndYWQLnf8eZOZwro5DDc";
            };
          });
        };
      };
    };
  };

  networking.firewall = {
    allowedUDPPorts = [24454];
  };
}
