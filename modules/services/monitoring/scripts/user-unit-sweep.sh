#!/usr/bin/env bash
# Emit Prometheus metrics for systemd units in per-user managers.
#
# node_exporter's systemd collector talks to the system manager only, so the
# rootless quadlets are invisible to it. Output goes to the textfile collector.

set -euo pipefail

TEXTFILE_DIR="${TEXTFILE_DIR:-/var/lib/node-exporter/textfile}"
LINGER_DIR="${LINGER_DIR:-/var/lib/systemd/linger}"
OUT="$TEXTFILE_DIR/homelab_user_units.prom"

# Podman's transient healthcheck units; mirrors --collector.systemd.unit-exclude.
TRANSIENT_RE='^[0-9a-f]{64}-[0-9a-f]{16}\.service$'

states=$(mktemp)
restarts=$(mktemp)
managers=$(mktemp)
tmp=$(mktemp "$OUT.XXXXXX")
trap 'rm -f "$states" "$restarts" "$managers" "$tmp"' EXIT

for user in $(ls -1 "$LINGER_DIR" 2>/dev/null || true); do
  if ! id -u "$user" >/dev/null 2>&1; then
    continue
  fi

  if ! units=$(systemctl --user -M "${user}@" list-units --type=service --all \
                 --no-legend --plain 2>/dev/null | awk '{print $1}'); then
    printf 'homelab_user_manager_up{user="%s"} 0\n' "$user" >>"$managers"
    continue
  fi
  printf 'homelab_user_manager_up{user="%s"} 1\n' "$user" >>"$managers"

  units=$(printf '%s\n' "$units" | grep -Ev "$TRANSIENT_RE" || true)
  [ -n "$units" ] || continue

  # shellcheck disable=SC2086
  systemctl --user -M "${user}@" show $units \
      -p Id -p ActiveState -p NRestarts -p Type 2>/dev/null |
    awk -v user="$user" -v states="$states" -v restarts="$restarts" '
      BEGIN { RS = ""; FS = "\n"; split("active activating deactivating inactive failed", all, " ") }
      {
        id = ""; st = ""; nr = "0"; type = ""
        for (i = 1; i <= NF; i++) {
          eq = index($i, "=")
          if (eq == 0) continue
          k = substr($i, 1, eq - 1); v = substr($i, eq + 1)
          if (k == "Id") id = v
          else if (k == "ActiveState") st = v
          else if (k == "NRestarts") nr = v
          else if (k == "Type") type = v
        }
        if (id == "" || st == "") next
        for (j in all)
          printf "homelab_user_unit_state{user=\"%s\",name=\"%s\",type=\"%s\",state=\"%s\"} %d\n",
                 user, id, type, all[j], (all[j] == st ? 1 : 0) >> states
        if (nr ~ /^[0-9]+$/)
          printf "homelab_user_unit_restart_total{user=\"%s\",name=\"%s\"} %s\n",
                 user, id, nr >> restarts
      }
    '
done

{
  echo "# HELP homelab_user_manager_up Whether the per-user systemd manager answered."
  echo "# TYPE homelab_user_manager_up gauge"
  cat "$managers"
  echo "# HELP homelab_user_unit_state systemd user unit state (1 = unit is in this state)."
  echo "# TYPE homelab_user_unit_state gauge"
  cat "$states"
  echo "# HELP homelab_user_unit_restart_total Number of times a user unit was restarted."
  echo "# TYPE homelab_user_unit_restart_total counter"
  cat "$restarts"
} >"$tmp"

chmod 0644 "$tmp"
mv "$tmp" "$OUT"
