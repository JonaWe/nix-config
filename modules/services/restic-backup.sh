#!/usr/bin/env bash

set -euo pipefail

echo "[INFO] Starting restic backup script"

STAGING_DIR="/mnt/restic_backups"

mkdir -p "$STAGING_DIR"

read -r -a DATASETS <<< "$ZFS_DATASETS"

cleanup() {
    echo "[INFO] Cleanup starting"

    for ds in "${DATASETS[@]}"; do
        TARGET_DIR="${STAGING_DIR}/${ds}"
        if mountpoint -q "$TARGET_DIR"; then
            echo "[DEBUG] Unmounting $TARGET_DIR"
            umount "$TARGET_DIR"
        else
            echo "[WARN] Cannot unmount: not mounted: $TARGET_DIR"
        fi
    done

    if [ -d "$STAGING_DIR" ]; then
        echo "[DEBUG] Removing staging directory: ${STAGING_DIR}"
        rm -rf "$STAGING_DIR"
    fi

    echo "[INFO] Cleanup complete"
}

trap cleanup EXIT

cleanup

echo "[INFO] Preparing bind mounts"

for ds in "${DATASETS[@]}"; do
    LATEST_SNAP_NAME=$(zfs list -t snapshot "$ds" -j | jq -r '.datasets[] | select(.name | test(".*daily")) | .name' | sort | tail -n 1 || true)
    if [ -z "$LATEST_SNAP_NAME" ]; then
        echo "[ERROR] Snapshot not found for dataset: ${ds}"
        continue
    fi
    echo "[DEBUG] Latest snapshot for dataset: ${ds} is: ${LATEST_SNAP_NAME}"

    TARGET_DIR="${STAGING_DIR}/${ds}"

    echo "[DEBUG] Mounting ${LATEST_SNAP_NAME} -> ${TARGET_DIR}"

    mkdir -p "$TARGET_DIR"

    mount -t zfs "$LATEST_SNAP_NAME" "$TARGET_DIR"
done

echo "[INFO] Backing up files"
restic backup "$STAGING_DIR" \
    --tag automated \
    --exclude-file=/etc/restic-excludes.txt \
    --exclude-if-present=".nobackup" \
    --exclude-caches \
    --compression=max

echo "[INFO] Forgetting old files"
restic forget \
    --keep-daily 24 \
    --keep-weekly 12 \
    --keep-monthly 12 \
    --group-by paths \
    --prune \
    --compression max

TODAY=$(date +%-d)
echo "[INFO] Checking repository integrity (Subset: $TODAY/31)"
restic check --read-data-subset=$TODAY/31

echo "[INFO] Restic backup complete"
