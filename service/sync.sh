#!/bin/sh

# Filament-Sync-Service sync loop
#
# This runs on the printer and copies the files that Filament-Sync (PC side)
# uploads into a staging directory into Creality's "live" CFS database folder.
#
# Defaults are tuned for Creality Hi.

CREALITYDIRECTORY="${CREALITYDIRECTORY:-/mnt/UDISK/creality/userdata/box}"
SYNCDIRECTORY="${SYNCDIRECTORY:-/usr/share/Filament-Sync}"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-15}"
# Guardrail: refuse to sync a suspiciously tiny DB (helps prevent accidental overwrites).
MIN_DB_BYTES="${MIN_DB_BYTES:-50000}"
LOGFILE="${LOGFILE:-/tmp/filamentsync.log}"

log() {
  # Best-effort logging (never crash the loop if logging fails)
  TS="$(date '+%F %T' 2>/dev/null || echo 'unknown-time')"
  echo "$TS $*" >> "$LOGFILE" 2>/dev/null || true
}

# Ensure directories exist (best effort)
mkdir -p "$CREALITYDIRECTORY" "$SYNCDIRECTORY" 2>/dev/null || true

COPY_MODE="cp"
if command -v rsync >/dev/null 2>&1; then
  COPY_MODE="rsync"
fi

log "Starting Filament-Sync-Service: CREALITYDIRECTORY=$CREALITYDIRECTORY SYNCDIRECTORY=$SYNCDIRECTORY interval=${INTERVAL_SECONDS}s min_db_bytes=$MIN_DB_BYTES copy=$COPY_MODE"

while :; do
  DB="$SYNCDIRECTORY/material_database.json"

  if [ ! -f "$DB" ]; then
    sleep "$INTERVAL_SECONDS"
    continue
  fi

  # File-size check (BusyBox-friendly)
  SIZE="$(wc -c < "$DB" 2>/dev/null | tr -d '[:space:]' || true)"
  if [ -n "$SIZE" ] && [ "$SIZE" -lt "$MIN_DB_BYTES" ]; then
    log "WARNING: material_database.json too small ($SIZE bytes < $MIN_DB_BYTES). Skipping sync."
    sleep "$INTERVAL_SECONDS"
    continue
  fi

  if [ "$COPY_MODE" = "rsync" ]; then
    rsync -a "$SYNCDIRECTORY/" "$CREALITYDIRECTORY/" >> "$LOGFILE" 2>&1 || log "ERROR: rsync failed (exit=$?)"
  else
    # BusyBox cp usually supports -a; if not, drop to a simpler copy.
    cp -af "$SYNCDIRECTORY/." "$CREALITYDIRECTORY/" >> "$LOGFILE" 2>&1 || cp -f "$SYNCDIRECTORY"/* "$CREALITYDIRECTORY/" >> "$LOGFILE" 2>&1 || log "ERROR: cp failed (exit=$?)"
  fi

  sleep "$INTERVAL_SECONDS"
done
