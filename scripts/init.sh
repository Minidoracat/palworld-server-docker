#!/bin/bash

if [[ ! "${PUID}" -eq 0 ]] && [[ ! "${PGID}" -eq 0 ]]; then
    printf "\e[0;32m*****PUID和PGID已设置*****\e[0m\n"
    usermod -o -u "${PUID}" steam
    groupmod -o -g "${PGID}" steam
else
    printf "\033[31mRunning as root is not supported, please fix your PUID and PGID!\n"
    exit 1
fi

mkdir -p /palworld/backups
chown -R steam:steam /palworld /home/steam/

term_handler() {
    if [ "${RCON_ENABLED}" = true ]; then
        rcon-cli "save"
        rcon-cli "shutdown 1 Server is shutting down."
    else # Does not save
        kill -SIGTERM "$(pidof PalServer-Linux-Test)"
    fi
    tail --pid=$killpid -f 2>/dev/null
}

trap 'term_handler' SIGTERM

su steam -c ./rcon.sh &
su steam -c ./start.sh &
# Process ID of su
killpid="$!"
while kill -0 $killpid 2>/dev/null; do
    sleep 1
done

kill 0
exit 0
