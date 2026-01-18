#!/bin/sh
set -eu

say() {
  echo "[filamentsync-service] $*"
}

if [ "$(id -u)" != "0" ]; then
  say "ERROR: Please run as root (or via sudo)."
  exit 1
fi

INIT_DST="/etc/init.d/filamentsync"
PATH_FILE="/etc/filamentsync.path"
LOG_FILE="/tmp/filamentsync.log"

if [ -x "$INIT_DST" ]; then
  say "Stopping service..."
  "$INIT_DST" stop 2>/dev/null || true
  say "Disabling service..."
  "$INIT_DST" disable 2>/dev/null || true
fi

say "Removing init script: $INIT_DST"
rm -f "$INIT_DST"

say "Removing path file: $PATH_FILE"
rm -f "$PATH_FILE"

say "(Optional) Leaving staging directory intact: /usr/share/Filament-Sync"
say "Log file is at: $LOG_FILE (not removed)"

say "Done."
