{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.minecraft-servers;
in {
  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];
  # imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myconf.services.minecraft-servers = {
    enable = lib.mkEnableOption "Enable minecraft servers config";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for jellyfin service";
    };
  };

  config = lib.mkIf cfg.enable {
    # services.minecraft-server.enable = true;
    # services.minecraft-server.eula = true;
    nixpkgs.overlays = [inputs.nix-minecraft.overlay];
    # networking.firewall.allowedTCPPorts = [ 25565 ];
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [25565];
      trustedInterfaces = ["tailscale0"];
    };

    # services.minecraft-server = {
    #   enable = true;
    #   eula = true;
    #   openFirewall = true; # Opens the port the server is running on (by default 25565 but in this case 43000)
    #   declarative = true;
    #   whitelist = {
    #     Jonaaaaaaaaa = "8977a987-8222-4eaf-8adf-720f34bc32c6";
    #     # This is a mapping from Minecraft usernames to UUIDs. You can use https://mcuuid.net/ to get a Minecraft UUID for a username
    #     # username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
    #     # username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
    #   };
    #   serverProperties = {
    #     server-ip = "";
    #     difficulty = 3;
    #     gamemode = 1;
    #     max-players = 5;
    #     # motd = "NixOS Minecraft server!";
    #     motd = "§kMinecraft Nix Test Server";
    #     white-list = false;
    #     allow-cheats = true;
    #   };
    #   jvmOpts = "-Xms2048M -Xmx4096M";
    # };

    services.minecraft-servers = {
      enable = true;
      eula = true;
      servers = {
        test-server = {
          openFirewall = cfg.openFirewall;
          enable = true;
          package = pkgs.fabricServers.fabric-1_21_4;
          serverProperties = {
            motd = "§kMinecraft Nix Test Server";
            level-name = "world";
            gamemode = "survival";
            difficulty = "hard";
            view-distance = 16;
            max-players = 666;
            simulation-distance = 16;
          };
          jvmOpts = "-Xms6144M -Xmx8192M";
          symlinks = {
            "ops.json" = pkgs.writeText "ops.json" (
              builtins.toJSON
              [
                {
                  uuid = "5e3a00aa-a56a-480d-bbd4-48be7e90f274";
                  name = "TheKos";
                  level = 4;
                  bypassesPlayerLimit = false;
                }
                {
                  uuid = "8977a987-8222-4eaf-8adf-720f34bc32c6";
                  name = "Jonaaaaaaaaa";
                  level = 4;
                  bypassesPlayerLimit = false;
                }
                {
                  uuid = "cdf47971-a41a-4ff5-bcb3-ad6b048d7da1";
                  name = "QuintusV";
                  level = 4;
                  bypassesPlayerLimit = false;
                }
              ]
            );
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
              # armorstands = pkgs.fetchurl {
              #   url = "https://cdn.modrinth.com/data/FlC9CXUY/versions/ywyjeMrW/armorstands-2.0.1%2B1.21.2.jar";
              #   hash = "sha256-uFEhb+h+SvNTOxh57+7rpHaicw/hxRmA+P5yttnA5qY=";
              # };
              # fabric-language-kotlin = pkgs.fetchurl {
              #   url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/csX9r2wS/fabric-language-kotlin-1.13.0%2Bkotlin.2.1.0.jar";
              #   hash = "sha256-in9nOy4TFb8svDzIaXU+III8Q/mqW+WW0PdNw8YmrZI=";
              # };
              # ledger = pkgs.fetchurl {
              #   url = "https://cdn.modrinth.com/data/LVN9ygNV/versions/a6TcvEKA/ledger-1.3.7.jar";
              #   hash = "sha256-EGfHgYa5ejJ4BDxR0DPAeFHkV35fqoBnusUqF6vV0KA=";
              # };
              # lithium = pkgs.fetchurl {
              #   url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/t1FlWYl9/lithium-fabric-0.14.3%2Bmc1.21.4.jar";
              #   hash = "sha256-LJFVhw/3MnsPnYTHVZbM3xJtne1lV5twuYeqZSMZEn4=";
              # };
              # vanish = pkgs.fetchurl {
              #   url = "https://cdn.modrinth.com/data/UL4bJFDY/versions/v24ijRym/vanish-1.5.9%2B1.21.4.jar";
              #   hash = "sha256-n0IkFzPjm+xprC0LzmejGiyndYWQLnf8eZOZwro5DDc";
              # };
            });
          };
        };
      };
    };
  };
}
