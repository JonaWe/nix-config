# NixOS Configurations

This repository ocntains the configuration for my nixos systems.

## Setup on a new system

```nix
sudo mv /etc/nixos /etc/nixos.bak  # Backup the original configuration
sudo ln -s ~/nixos-config /etc/nixos

# Deploy the flake.nix located at the default location (/etc/nixos)
sudo nixos-rebuild switch
```

