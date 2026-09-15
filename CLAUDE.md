# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy Commands

```bash
# Apply configuration to the current host
sudo nixos-rebuild switch --flake /home/jona/nix-config

# Build without switching (dry run / check)
sudo nixos-rebuild build --flake /home/jona/nix-config

# Target a specific host
sudo nixos-rebuild switch --flake /home/jona/nix-config#<hostname>

# Deploy to a new machine via nixos-anywhere
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config \
  ./hosts/<hostname>/hardware-configuration.nix \
  --flake .#<hostname> --target-host root@<ip>

# Validate nix syntax
nix flake check
```

## Architecture

This is a multi-host NixOS flake configuration managing 4 machines. All configuration is x86_64-linux.

### Flake Structure

- **nixpkgs** (26.05 stable) + **nixpkgs-unstable** for select packages
- **home-manager** (release-26.05) integrated as a NixOS module
- **sops-nix** for secrets (age-encrypted, stored in a separate private repo `nix-secrets`)
- **disko** for declarative disk partitioning
- **authentik-nix** for identity provider integration

### Hosts

| Host | Role | Desktop | Key Features |
|------|------|---------|--------------|
| `ant` | Homelab server | None | 40+ containerized services, ZFS (root+data pools), NVIDIA GPU, Podman quadlets |
| `albatross` | VPS/remote | None | Headscale, Authentik, nginx reverse proxy |
| `octopus` | Gaming desktop | Sway | NVIDIA, Steam, Syncthing |
| `pangolin` | Laptop/dev | Hyprland+UWSM | AMD GPU, kanata homerow mods, libvirtd, development tools |

### Directory Layout

- `flake.nix` — Entry point. Defines all 4 host configurations with shared `specialArgs` (`pkgs-unstable`, `username`, `inputs`).
- `hosts/<hostname>/` — Per-host config. Each has `default.nix` (imports specific modules, sets host-specific options) and `hardware-configuration.nix`.
- `modules/` — Reusable NixOS modules, auto-imported via `modules/default.nix` which pulls in `disk/` and `services/`.
- `modules/base.nix` — Shared base config (user creation, nix settings, locale, shell, core packages).
- `modules/services/` — ~40 service modules, each behind `myconf.services.<name>.enable` options.
- `modules/disk/` — ZFS root/data pool and ext4 disk management via `myconf.disk.*` options.
- `users/jona/` — User config: `nixos.nix` (system-level user), `base-home.nix` (CLI tools), `sway-home.nix` (extends base with desktop apps).
- `home/programs/` — Home Manager program configs (neovim, tmux, kitty, sway, browser, etc.).

### Custom Option Namespaces

Modules use two custom option namespaces:

- **`myconf.services.<name>`** — Service modules (e.g., `myconf.services.tailscale.enable`, `myconf.services.syncthing.enable`). Each follows the pattern: define options under `myconf.services.<name>`, use `let cfg = config.myconf.services.<name>` and guard with `lib.mkIf cfg.enable`.
- **`myconf.disk`** — Disk management (root pool, data pool, ext4 config).

### Homelab Service Framework

`modules/services/homelab.nix` defines a higher-level `homelab.services` option (separate from `myconf.services`) for Podman quadlet-based containers on `ant`. Each service declared under `homelab.services.<name>` auto-generates:
- Podman container from a quadlet `.container` file
- User/group creation with lingering
- Firewall port opening
- Nginx reverse proxy vhost (with ACME via `pinkorca.de`)
- ZFS dataset mounts with sanoid snapshot policies
- Permission-setting systemd oneshot services

#### Rootless containers and file ownership

A `rootless = true` service runs podman as its own service user, so **container
root is that user**, and the ZFS mounts it writes end up owned by that uid.

If the image drops to a non-root user (apache runs as `www-data`, eclipse-mosquitto
as `mosquitto`), that user is *not* container root and cannot write the mounted
data — it sees the tree as `root:root 0775`. The failure is a confusing one,
because the container starts and only writes fail: nextcloud answered 500 with
SQLite reporting "attempt to write a readonly database".

Map the host's service user onto the uid the image actually runs as:

```
UserNS=keep-id:uid=33,gid=33
```

Check the image before adding a service, and again when migrating one to
rootless. Derive the uid rather than guessing it — from a running container,
`<host uid of the container PID> - <subuid start from /etc/subuid> + 1`.

`keep-id` also means the entrypoint no longer starts as container root, so an
image binding a privileged port needs the floor lowered in its own network
namespace as well:

```
Sysctl=net.ipv4.ip_unprivileged_port_start=80
```

Quadlet splits `Environment=` on spaces to separate `KEY=VALUE` pairs. A value
containing a space needs quotes around the value, not the pair:
`Environment=TRUSTED_PROXIES="127.0.0.1 10.88.0.0/16"`.

A `nixos-rebuild switch` does **not** restart rootless services — it only relinks
the quadlet and runs a daemon-reload, so the container keeps its old definition.
Restart it explicitly:

```bash
runuser -u <name> -- env XDG_RUNTIME_DIR=/run/user/$(id -u <name>) \
  systemctl --user restart <name>.service
```

### Secrets

Secrets are managed via sops-nix with age encryption. The encrypted secrets live in a separate git repo (`git+ssh://git@github.com/JonaWe/nix-secrets.git`) referenced as the `mysecrets` flake input. Age key is at `/root/.config/sops/age/keys.txt`. Services reference secrets via `config.sops.secrets."path/to/secret".path`.

### Module Conventions

- Standalone modules (sway, hyprland, ssh, docker, fonts, etc.) are imported explicitly per-host in `hosts/<hostname>/default.nix`.
- Service modules under `modules/services/` are all auto-imported via `modules/services/default.nix` but gated behind `enable` options — they do nothing unless enabled in a host config.
- Unstable packages are accessed via `pkgs-unstable` (passed through `specialArgs`).
- The `username` variable ("jona") is passed via `specialArgs` and used throughout for user-specific paths.
