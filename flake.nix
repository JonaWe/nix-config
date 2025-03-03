{
  description = "Configuration for nix os systems";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mysecrets = {
      url = "git+ssh://git@github.com/JonaWe/nix-secrets.git?shallow=1";
      flake = false;
    };
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  }: let
    username = "jona";
    specialArgs = {
      pkgs-unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      inherit username inputs;
    };
  in {
    nixosConfigurations = {
      ant = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";

        modules = [
          ./hosts/ant
          ./users/jona/nixos.nix
          ./modules

          inputs.disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = ".hm.bak";
            home-manager.users.${username} = import ./users/${username}/base-home.nix;
          }
        ];
      };
      octopus = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";

        modules = [
          ./hosts/octopus
          ./users/jona/nixos.nix
          ./modules

          inputs.disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = ".hm.bak";
            home-manager.users.${username} = import ./users/${username}/sway-home.nix;
          }
        ];
      };
      pangolin = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/pangolin
          ./users/jona/nixos.nix
          ./modules

          inputs.disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = ".hm.bak";
            home-manager.users.${username} = import ./users/${username}/sway-home.nix;
          }
        ];
      };
    };
  };
}
