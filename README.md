# NixOS Configurations

This repository ocntains the configuration for my nixos systems.

```nix
nix.settings.experimental-features = ["nix-command" "flakes"];
add git to packages
```

```bash
git clone https://github.com/JonaWe/nix-config.git
```

## Setup on a new system

```nix
sudo mv /etc/nixos /etc/nixos.bak  # Backup the original configuration
sudo ln -s ~/nixos-config /etc/nixos

# Deploy the flake.nix located at the default location (/etc/nixos)
sudo nixos-rebuild switch
```

