#!/bin/bash

# Path to the flag file
flag_file="/tmp/memory_over_80.flag"

# Function to check memory usage and perform corresponding actions
check_memory_usage() {
    if [ "${AUTO_SHUTDOWN}" = true ]; then
        printf "\e[0;32m*****AUTO_SHUTDOWN IS ENABLED*****\e[0m\n"
    else
        printf "\e[0;32m*****AUTO_SHUTDOWN IS DISABLED*****\e[0m\n"
        [ -f "/sys/fs/cgroup/memory/memory.limit_in_bytes" ] || return
    fi

    while true; do
        total_memory=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
        memory_usage=$(cat /sys/fs/cgroup/memory/memory.usage_in_bytes)
        usage_percent=$(awk "BEGIN {print ($memory_usage/$total_memory)*100}")

        if (( $(echo "$usage_percent > 98" | bc -l) )); then
            rcon-cli save
            rcon-cli shutdown 5 "Server is restarting in 5 seconds due to memory leak."
        elif (( $(echo "$usage_percent > 80" | bc -l) )); then
            if [ ! -f "$flag_file" ]; then
                rcon-cli save
                rcon-cli broadcast "Current_memory_usage_is_over_80%."
                touch "$flag_file"
            fi
        elif (( $(echo "$usage_percent < 65" | bc -l) )); then
            [ -f "$flag_file" ] && rm "$flag_file"
        fi
        sleep 5
    done
}


# Function to report memory usage every ten minutes
report_memory_usage() {
    while true; do
        total_memory=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
        memory_usage=$(cat /sys/fs/cgroup/memory/memory.usage_in_bytes)
        usage_percent=$(awk "BEGIN {print ($memory_usage/$total_memory)*100}")

        rcon-cli broadcast Server_current_memory_usage:_${usage_percent}%.

        sleep 1800
    done
}


# Function to backup the server every 1 hour
backup_server() {
    sleep 600
    if [ "${AUTO_BACKUP}" = true ]; then
        printf "\e[0;32m*****AUTO_BACKUP IS ENABLED*****\e[0m\n"
    else
        printf "\e[0;32m*****AUTO_BACKUP IS DISABLED*****\e[0m\n"
        return
    fi
    while true; do
        rcon-cli save
        rcon-cli broadcast Server_is_backing_up.
        DATE=$(date +"%Y-%m-%d_%H-%M-%S")
        FILE_PATH="/palworld/backups/palworld-save-${DATE}.tar.gz"
        BACKUP_DIR="/palworld/backups"

        cd /palworld/Pal/ || exit

        tar -zcf "$FILE_PATH" "Saved/"
        echo "Backup created at $FILE_PATH"

        cd "$BACKUP_DIR" || exit
        ls -1t | tail -n +31 | xargs -d '\n' rm -f --

        sleep 3600
    done
}

# Run the functions in the background
sleep 30
echo ""
printf "\e[0;32m*****STARTING RCON*****\e[0m\n"
check_memory_usage &
report_memory_usage &
backup_server &

# Wait for background tasks to complete
wait

