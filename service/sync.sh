#!/bin/sh

CREALITYDIRECTORY="/mnt/UDISK/creality/userdata/box"
SYNCDIRECTORY="/mnt/UDISK/printer_data/config/Filament-Sync-Service/data"

while :
do
    if test -f "$SYNCDIRECTORY/material_database.json"; then
        rsync -a ${SYNCDIRECTORY}/ ${CREALITYDIRECTORY}
    fi
    sleep 15
done