# NixOS Configurations

This repository contains the configuration for my nixos systems. This readme is also a collection of some important commands.

## Install

Either use nixos anywhere or the NixOS Installer and clone the repo afterwards.

### nixos-anywhere

```bash
nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hosts/<hostname>/hardware-configuration.nix --flake .#<hostname> --target-host root@<ip address>
```

Copy over the secrets.

Rebuild the system:

```nix
sudo nixos-rebuild switch --flake ~/nixos-config
```

### NixOS Installer

Use the installer for the installation if you want to configure the disk layout that way.

Then enable the following option:

```nix
nix.settings.experimental-features = ["nix-command" "flakes"];
```

Additionally add `git` to the system packages.

Copy over the secrets.

Clone the repo:

```bash
git clone git@github.com:JonaWe/nix-config.git
```

Rebuild the system:

```nix
sudo nixos-rebuild switch --flake ~/nixos-config

## Reformat disk

This is an experimental feature and should not be used if you have important data on your drive.

```bash
disko --mode format --dry-run ./hosts/<hostname>/disko-config.nix

```

Forward port via ssh for syncthing setup

```bash
ssh -L 9998:localhost:8384 home.lab
```

