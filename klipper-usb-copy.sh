#!/bin/bash
# klipper-usb-copy.sh
# Automatically copies G-code files from a USB drive to Klipper's gcode folder.
# Triggered by udev via systemd when a USB storage device is plugged in.

# ── Configuration ────────────────────────────────────────────────────────────
KLIPPER_GCODE_DIR="/home/pi/printer_data/gcodes"   # adjust if your path differs
MOUNT_POINT="/mnt/usb_klipper"
LOG_FILE="/var/log/klipper-usb-copy.log"
DEVICE="/dev/$1"                                    # e.g. /dev/sda1, passed from systemd
# ─────────────────────────────────────────────────────────────────────────────

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "--- USB copy triggered for device: $DEVICE ---"

# Bail out if device doesn't exist
if [ ! -b "$DEVICE" ]; then
    log "ERROR: $DEVICE is not a block device. Exiting."
    exit 1
fi

# Create mount point if it doesn't exist
mkdir -p "$MOUNT_POINT"

# Mount the USB drive (read-only is fine for copying from it)
if ! mount -o ro "$DEVICE" "$MOUNT_POINT" 2>>"$LOG_FILE"; then
    log "ERROR: Failed to mount $DEVICE. Exiting."
    exit 1
fi
log "Mounted $DEVICE at $MOUNT_POINT"

# Ensure destination exists
mkdir -p "$KLIPPER_GCODE_DIR"

# Copy all G-code files (recurse into subdirectories, preserve folder structure)
COPIED=0
SKIPPED=0
while IFS= read -r -d '' src_file; do
    # Build destination path mirroring the USB subdirectory layout
    rel_path="${src_file#$MOUNT_POINT/}"
    dst_file="$KLIPPER_GCODE_DIR/$rel_path"
    dst_dir="$(dirname "$dst_file")"

    mkdir -p "$dst_dir"

    if [ -f "$dst_file" ]; then
        # Skip if an identical file already exists (compare size + mtime)
        if [ "$src_file" -nt "$dst_file" ] || [ "$(stat -c%s "$src_file")" != "$(stat -c%s "$dst_file")" ]; then
            cp "$src_file" "$dst_file" && log "  Updated: $rel_path" && (( COPIED++ )) || log "  FAILED to copy: $rel_path"
        else
            log "  Skipped (unchanged): $rel_path"
            (( SKIPPED++ ))
        fi
    else
        cp "$src_file" "$dst_file" && log "  Copied:  $rel_path" && (( COPIED++ )) || log "  FAILED to copy: $rel_path"
    fi
done < <(find "$MOUNT_POINT" -type f \( -iname "*.gcode" -o -iname "*.g" -o -iname "*.gc" -o -iname "*.gco" \) -print0)

log "Done. Copied: $COPIED  Skipped (unchanged): $SKIPPED"

# Unmount cleanly
umount "$MOUNT_POINT" && log "Unmounted $DEVICE" || log "WARNING: Failed to unmount $DEVICE"

exit 0
