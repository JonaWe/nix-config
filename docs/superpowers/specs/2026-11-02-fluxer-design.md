# Fluxer voice chat on ant

## Goal

Run a self-hosted [Fluxer](https://docs.fluxer.com) instance on `ant` for
voice chat among people on the tailnet.

## Decisions

| Question | Decision |
|----------|----------|
| Reachability | Tailnet only, like every other web service on `ant` |
| Deployment | Upstream Docker Compose bundle, run by a systemd unit |
| Sign-in | Local accounts, username mode (no SMTP), registration by invite |

Rejected deployments: compose2nix into `virtualisation.oci-containers` (systemd
cannot express `depends_on: service_healthy`, so the ~10 microservices race on
start, and every release means regenerating ~1500 lines), and hand-written
podman quadlets (21 files whose image digests would have to be tracked by
hand). The bundle is the only install path upstream maintains.

## Upstream facts this design relies on

- Release `fluxer-release@2026.1102.171206`, asset
  `fluxer-compose-2026.1102.171206.tar.gz`. The tarball has no top-level
  directory. All Fluxer images inside are pinned by digest.
- The stack is 21 containers: edge (caddy), postgres, valkey, nats,
  meilisearch, seaweedfs, seaweedfs-init, livekit, api, worker, gateway,
  media-proxy, push, static-proxy, app-proxy, snowflakes, users, gifs,
  messages, unfurl, admin.
- `docker-compose.proxy.yml` binds edge to `FLUXER_EDGE_BIND`
  (default `127.0.0.1:8080`) without TLS, for an outer reverse proxy.
- LiveKit signalling is served by edge under `/livekit`; media goes directly to
  the host on TCP 7881 and UDP 7882.
- The compose file refuses to start unless `FLUXER_SETTINGS_LOADED=true`.
- Database, search and push keys must never change after the first start.

## Architecture

### Module

`modules/services/fluxer/fluxer.nix`, imported from
`modules/services/default.nix`, gated by `myconf.services.fluxer.enable` and
enabled in `hosts/ant/default.nix`.

### Bundle

Fetched with `pkgs.fetchzip` (`stripRoot = false`) from the GitHub release URL,
pinned by version and hash. Compose resolves the bundle's relative bind mounts
(`./Caddyfile`, `./caddy.d`, `./certs`, `./ca`) against the first compose
file's directory, i.e. the read-only store path, which is all they need.

### Override file

A Nix-generated `fluxer.override.yml`, passed as the last `-f`:

- Rebinds every named volume to a directory under `/opt/services/fluxer`:
  `postgres`, `valkey`, `nats`, `meilisearch`, `seaweedfs`, `edge-data`,
  `edge-config`. `media-proxy-tmp` stays a named volume, it is scratch space.
- Replaces livekit's `ports` (`!override`) with
  `100.64.0.2:7881:7881` and `100.64.0.2:7882:7882/udp`. Docker's published
  ports bypass the NixOS firewall, so binding to `0.0.0.0` would expose them to
  the LAN and the internet regardless of `networking.firewall`.

### Environment

Compose gets two `--env-file`s:

1. A Nix-generated, non-secret file:
   - `FLUXER_SETTINGS_LOADED=true`
   - `FLUXER_DOMAIN=fluxer.ts.pinkorca.de`
   - `FLUXER_EDGE_BIND=127.0.0.1:8095` (8080 is taken by unifi-controller's inform port on `0.0.0.0`)
   - `FLUXER_LIVEKIT_USE_EXTERNAL_IP=false`
   - `FLUXER_LIVEKIT_NODE_IP=100.64.0.2`
   - memory limits (see below)
2. The sops secret `fluxer/env` (dotenv block), holding:
   `FLUXER_SETUP_TOKEN`, `POSTGRES_PASSWORD`, `MEILI_MASTER_KEY`,
   `FLUXER_S3_SECRET_KEY`, `LIVEKIT_API_SECRET`, `FLUXER_SUDO_MODE_SECRET`,
   `FLUXER_CONNECTION_INITIATION_SECRET`, `FLUXER_PROFILE_PSEUDONYM_SECRET`,
   `FLUXER_GATEWAY_RPC_AUTH_TOKEN`, `FLUXER_ERLANG_COOKIE`,
   `FLUXER_MEDIA_PROXY_SECRET_KEY`, `FLUXER_ADMIN_SECRET_KEY_BASE`,
   `FLUXER_ADMIN_OAUTH_CLIENT_SECRET`,
   `FLUXER_MEDIA_PROXY_UPLOAD_RELAY_SECRET_BASE64`,
   `FLUXER_ACTIVITYPUB_SIGNING_KEY_BASE64`, `FLUXER_VAPID_PUBLIC_KEY`,
   `FLUXER_VAPID_PRIVATE_KEY`.

`FLUXER_S3_ACCESS_KEY` and `LIVEKIT_API_KEY` are set to `fluxer` in the Nix
file. That value is fixed by `.env.example` only; the compose file defaults
both to empty, which leaves LiveKit unable to parse its keys.

### systemd unit

`fluxer.service`, `Type=oneshot`, `RemainAfterExit=true`:

- `after`/`requires` `docker.service`, `RequiresMountsFor=/opt/services/fluxer`
- `ExecStart`: `docker compose -p fluxer -f <bundle>/docker-compose.yml
  -f <bundle>/docker-compose.proxy.yml -f <override>
  --env-file <nix-env> --env-file <sops-env> up -d --remove-orphans --wait`
- `ExecStop`: the same invocation with `down`
- `TimeoutStartSec` generous (first start pulls ~20 images)
- `Restart=on-failure`, `RestartSec=30s`: on a fresh data directory postgres
  answers `pg_isready` from its socket-only init server before it listens on
  TCP, so `users` crash-loops briefly and `--wait` fails the first start
- `restartTriggers` on the bundle, override and env files, so a version bump
  or config change is applied by `nixos-rebuild switch`

### Reverse proxy

nginx vhost `fluxer.ts.pinkorca.de`, `useACMEHost = "pinkorca.de"` (covered by
the existing `*.ts.pinkorca.de` name), `forceSSL`, proxying `/` to
`127.0.0.1:8095` with the settings the upstream reverse-proxy docs require:

- WebSocket upgrade
- `client_max_body_size 512m`
- `proxy_read_timeout` / `proxy_send_timeout 3600s`
- `proxy_buffering off`, `proxy_request_buffering off`
- `X-Forwarded-For $remote_addr`, overriding the
  `$proxy_add_x_forwarded_for` set by `recommendedProxySettings`

### Firewall

No change. `tailscale0` is already a trusted interface, and the LiveKit ports
are only published on the tailnet address.

## Data and backup

- One dataset `zdata/enc/services/fluxer`, `mountpoint=legacy`, mounted on
  `/opt/services/fluxer` via `fileSystems`. It is created once by hand on
  `ant` (`zfs create -o mountpoint=legacy zdata/enc/services/fluxer`), like the
  other service datasets.
- Sanoid snapshots with the `default` template.
- Offsite restic backup: `restic-backup.nix` only collects datasets from
  `homelab.services.*.zfsMounts`. Fluxer is not a homelab service, so add a
  `homelab.extraBackupDatasets` list option and include it there.
- The restic job reads from ZFS snapshots, so the live postgres data directory
  is backed up crash-consistently.

## Resources

`ant` has 31 GB RAM with ~9 GB available and swap already in use. The bundle's
defaults reserve far more than a handful of users need, so the Nix env file
sets:

| Service | Setting |
|---------|---------|
| postgres | `FLUXER_POSTGRES_MEMORY_LIMIT=1gb`, `FLUXER_POSTGRES_MEMORY_RESERVATION=0`, `FLUXER_POSTGRES_SHARED_BUFFERS=256MB`, `FLUXER_POSTGRES_EFFECTIVE_CACHE_SIZE=768MB`, `FLUXER_POSTGRES_SHM_SIZE=256mb` |
| api | `FLUXER_API_MEMORY_LIMIT=768mb`, `FLUXER_API_MEMORY_RESERVATION=0` |
| worker | `FLUXER_WORKER_MEMORY_LIMIT=768mb`, `FLUXER_WORKER_MEMORY_RESERVATION=0` |
| meilisearch | `FLUXER_MEILISEARCH_MEMORY_LIMIT=512mb` |
| seaweedfs | `FLUXER_SEAWEEDFS_MEMORY_LIMIT=512mb`, `FLUXER_SEAWEEDFS_GOMEMLIMIT=400MiB` |

Each variable name must be checked against `docker-compose.yml` during
implementation. A reservation of `0` must be accepted by compose; if it is
not, drop the reservation via the override file instead.

## Rollout

1. User adds `fluxer/env` to `nix-secrets` and bumps the `mysecrets` input.
2. Create the dataset on `ant`.
3. Rebuild on `ant` itself (`--flake path:` over SSH as root).
4. Verify (below).
5. User opens `https://fluxer.ts.pinkorca.de`, enters `FLUXER_SETUP_TOKEN`,
   picks username mode, creates the admin, and sets registration to invite
   only in the admin panel.

## Verification

- `nix flake check` / build on `ant` succeeds.
- `systemctl status fluxer` is active; `docker compose -p fluxer ps` shows
  every service healthy and `seaweedfs-init` exited 0.
- `curl https://fluxer.ts.pinkorca.de/_health` returns 200 from a tailnet
  host.
- `curl https://fluxer.ts.pinkorca.de/livekit/` answers `OK`.
- `ss -lntup` on `ant` shows 7881/7882 bound to `100.64.0.2` only.
- User joins a voice channel from two tailnet clients.

## Updating

Bump version and hash in the module and rebuild. Before an upgrade, compare the
new `.env.example` for new required settings. `homelab.autoUpdate` does not
apply; it only drives podman.

## Out of scope

- Access from outside the tailnet (voice would need a TURN relay or forwarded
  media ports on `albatross`).
- Authentik SSO. It can be added later in the admin panel without changing
  this module.
- Email/SMTP.
