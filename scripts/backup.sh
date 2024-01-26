#!/bin/bash

if [ "${RCON_ENABLED}" = true ]; then
    rcon-cli save
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
FILE_PATH="/palworld/backups/palworld-save-${DATE}.tar.gz"
BACKUP_DIR="/palworld/backups"

cd /palworld/Pal/ || exit

tar -zcf "$FILE_PATH" "Saved/"
echo "Backup created at $FILE_PATH"

cd "$BACKUP_DIR" || exit
ls -1t | tail -n +31 | xargs -d '\n' rm -f --

echo "Old backups cleaned up, if necessary."

