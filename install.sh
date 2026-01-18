#!/bin/sh
set -eu

# Filament-Sync-Service installer (Creality Hi friendly)
#
# What this does:
#   - Installs an OpenWrt init script at /etc/init.d/filamentsync
#   - Writes the absolute path to the real sync script into /etc/filamentsync.path
#   - Enables + starts the service

say() {
  echo "[filamentsync-service] $*"
}

need_root() {
  if [ "$(id -u)" != "0" ]; then
    say "ERROR: Please run as root (or via sudo)."
    exit 1
  fi
}

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SYNC_SH="$SCRIPT_DIR/service/sync.sh"
INIT_SRC="$SCRIPT_DIR/service/init.d/filamentsync"

INIT_DST="/etc/init.d/filamentsync"
PATH_FILE="/etc/filamentsync.path"
STAGING_DIR="/usr/share/Filament-Sync"
LOG_FILE="/tmp/filamentsync.log"

need_root

say "Installing from: $SCRIPT_DIR"

if [ ! -f "$SYNC_SH" ]; then
  say "ERROR: Missing $SYNC_SH"
  exit 1
fi

if [ ! -f "$INIT_SRC" ]; then
  say "ERROR: Missing $INIT_SRC"
  exit 1
fi

chmod 0755 "$SYNC_SH" 2>/dev/null || true
chmod 0755 "$INIT_SRC" 2>/dev/null || true

say "Writing sync path to: $PATH_FILE"
echo "$SYNC_SH" > "$PATH_FILE"
chmod 0644 "$PATH_FILE" 2>/dev/null || true

say "Installing init script to: $INIT_DST"
cp -a "$INIT_SRC" "$INIT_DST"
chmod 0755 "$INIT_DST"

say "Ensuring staging dir exists: $STAGING_DIR"
mkdir -p "$STAGING_DIR"
chmod 0755 "$STAGING_DIR" 2>/dev/null || true

# Touch log file so tail works immediately (best effort)
touch "$LOG_FILE" 2>/dev/null || true

# Enable + start
if [ -x "$INIT_DST" ]; then
  "$INIT_DST" enable 2>/dev/null || true

  # Not all builds have 'restart' implemented; try restart then fallback.
  if "$INIT_DST" restart 2>/dev/null; then
    :
  else
    "$INIT_DST" stop 2>/dev/null || true
    "$INIT_DST" start 2>/dev/null || true
  fi
fi

say "Done."
say "Status:   $INIT_DST status"
say "Logs:     tail -n 200 $LOG_FILE"
say "Staging:  $STAGING_DIR"
