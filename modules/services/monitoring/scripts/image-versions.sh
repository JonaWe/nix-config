#!/usr/bin/env bash
# Report, per running container, which image version runs and which is available.
#
# Service-centric on purpose: one row per container, not per registry tag.
# Candidates are matched by comparing tag shape — digits collapsed to "#" — so
# 3.7.2 only ever competes with 3.7.7 and never with a build number, and no
# regex has to be constructed or escaped.
set -euo pipefail

TEXTFILE_DIR="${TEXTFILE_DIR:-/var/lib/node-exporter/textfile}"
LINGER_DIR="${LINGER_DIR:-/var/lib/systemd/linger}"
OUT="$TEXTFILE_DIR/homelab_image_versions.prom"

rows=$(mktemp)
tmp=$(mktemp "$OUT.XXXXXX")
trap 'rm -f "$rows" "$tmp"' EXIT

emit() { # service runtime repo current available state
  printf 'homelab_image_info{service="%s",runtime="%s",repo="%s",current="%s",available="%s",state="%s"} 1\n' \
    "$1" "$2" "$3" "$4" "$5" "$6" >>"$rows"
}

# Registries rate-limit, and a single blip would read the same as "tag gone".
newest_tag() { # repo current-tag
  local out
  for attempt in 1 2 3; do
    out=$(list_matching "$1" "$2")
    [ -n "$out" ] && { printf '%s\n' "$out"; return 0; }
    sleep $((attempt * 5))
  done
  return 1
}

list_matching() { # repo current-tag
  skopeo list-tags "docker://$1" 2>/dev/null |
    grep -oE '"[^"]+"' | tr -d '"' |
    awk -v cur="$2" '
      function shape(s) { gsub(/[0-9]+/, "#", s); return s }
      BEGIN { want = shape(cur) }
      shape($0) == want { print }
    ' |
    sort -V | tail -1
}

check() { # service runtime image
  local svc=$1 rt=$2 image=$3 repo tag newest
  repo=${image%:*}
  tag=${image##*:}
  if [ "$repo" = "$image" ]; then repo=$image; tag=latest; fi

  case "$tag" in
    latest | stable | main | edge | dev | beta | nightly)
      emit "$svc" "$rt" "$repo" "$tag" "" mutable
      return
      ;;
  esac

  newest=$(newest_tag "$repo" "$tag" || true)
  if [ -z "$newest" ]; then
    emit "$svc" "$rt" "$repo" "$tag" "" unreachable
  elif [ "$newest" = "$tag" ]; then
    emit "$svc" "$rt" "$repo" "$tag" "$tag" current
  else
    emit "$svc" "$rt" "$repo" "$tag" "$newest" update
  fi
}

scan() { # runtime  (reads "name image" pairs on stdin)
  while read -r name image; do
    [ -n "${name:-}" ] || continue
    check "$name" "$1" "$image"
  done
}

# runuser rather than su: shadow ships no su on NixOS, it is a setuid wrapper.
# It keeps the caller's cwd, which the service user cannot read, and it does not
# set XDG_RUNTIME_DIR, so podman would look for its socket under root's.
command -v runuser >/dev/null || { echo "runuser missing, rootless containers would be skipped" >&2; exit 1; }
cd /

found=0
for user in $(ls -1 "$LINGER_DIR" 2>/dev/null || true); do
  uid=$(id -u "$user" 2>/dev/null) || continue
  while read -r name image; do
    [ -n "${name:-}" ] || continue
    found=$((found + 1))
    check "$name" podman "$image"
  done < <(runuser -u "$user" -- env "XDG_RUNTIME_DIR=/run/user/$uid" \
             podman ps --format '{{.Names}} {{.Image}}' 2>/dev/null || true)
done
[ "$found" -gt 0 ] || echo "no rootless containers found across $(ls -1 "$LINGER_DIR" | wc -l) users" >&2

# The quadlets that deliberately stayed rootful.
podman ps --format '{{.Names}} {{.Image}}' 2>/dev/null | scan podman-system || true
docker ps --format '{{.Names}} {{.Image}}' 2>/dev/null | scan docker || true

{
  echo "# HELP homelab_image_info Running image version and the newest matching tag available."
  echo "# TYPE homelab_image_info gauge"
  sort -u "$rows"
} >"$tmp"

chmod 0644 "$tmp"
mv "$tmp" "$OUT"
