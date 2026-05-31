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

  options.myconf.services.minecraft-servers = {
    enable = lib.mkEnableOption "Enable minecraft servers config";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for minecraft service";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [inputs.nix-minecraft.overlay];

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [25565];
      trustedInterfaces = ["tailscale0"];
    };

    services.minecraft-servers = {
      enable = true;
      eula = true;
      servers = {
        test-server = {
          openFirewall = cfg.openFirewall;
          enable = true;
          package = pkgs.vanillaServers.vanilla-26_1_2;
          serverProperties = {
            motd = "Minecraft <3";
            level-name = "world-js";
            gamemode = "survival";
            difficulty = "normal";
            view-distance = 16;
            seed = 1011001010111010100;
            max-players = 2;
            simulation-distance = 16;
          };
          jvmOpts = "-Xms6144M -Xmx8192M";
          symlinks = {
            "ops.json" = pkgs.writeText "ops.json" (
              builtins.toJSON
              [
                {
                  uuid = "8977a987-8222-4eaf-8adf-720f34bc32c6";
                  name = "Jonaaaaaaaaa";
                  level = 4;
                  bypassesPlayerLimit = false;
                }
              ]
            );
          };
        };
      };
    };
  };
}
