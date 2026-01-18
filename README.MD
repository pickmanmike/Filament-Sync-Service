Filament-Sync-Service (Creality Hi friendly fork)

This is a **fork** of the original Filament-Sync-Service project.

It’s a small *printer-side* companion for **Filament-Sync**:

- **Filament-Sync** (PC side) generates / uploads Creality material database files.
- **Filament-Sync-Service** (printer side) copies those files into the Creality Hi “live” database folder so the printer UI / CFS can actually see them.

This fork mainly adds:

- Creality Hi friendly install behavior
- Guardrails to avoid overwriting the live database with tiny files
- Slightly more logging / configurability

## Install (Creality Hi)

1. Copy the repo folder to the printer:

   - Destination: `/mnt/UDISK/printer_data/config/Filament-Sync-Service`

   WinSCP (SCP) works well, or any `scp` client.

### In Terminal/Powershell on your pc

Connect to your printer with ssh ```root@<your.printer.ip>```
password ```Creality2024```

Install the sync service
```
cd /mnt/UDISK/printer_data/config/Filament-Sync-Service/
```
```
sh /install.sh
```

## Configure

Edit `service/sync.sh`:

- `CREALITYDIRECTORY` (default: `/mnt/UDISK/creality/userdata/box`)
- `SYNCDIRECTORY` (default: `/usr/share/Filament-Sync`)
- `INTERVAL_SECONDS` (default: `15`)
- `MIN_DB_BYTES` (default: `50000`)

After edits, restart:

```sh
/etc/init.d/filamentsync restart || ( /etc/init.d/filamentsync stop; /etc/init.d/filamentsync start )
```

## What this fork intentionally does NOT do

Some Klipper setups integrate with Moonraker’s `update_manager` so Fluidd/Mainsail can one-click update.

On appliance firmware builds (including many Creality variants), `update_manager` behavior can be patched, incomplete, or brittle. This fork **does not modify** Moonraker configs by default.

#### All done! Continue to install Filament-Sync on your PC via the companion fork of Filamen-Sync for Creality Print 6 & 7 and the Creality Hi
### [Filament-Sync](https://github.com/pickmanmike/Filament-Sync)

## Credit

All original credit goes to HurricanePrint for Filament-Sync and Filament-Sync-Service.
