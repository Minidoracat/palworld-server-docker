#!/bin/bash

STARTCOMMAND="./PalServer.sh"

if [ -n "${PORT}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -port=${PORT}"
fi

if [ -n "${PLAYERS}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -players=${PLAYERS}"
fi

if [ "${COMMUNITY}" = true ]; then
    STARTCOMMAND="${STARTCOMMAND} EpicApp=PalServer"
fi

if [ -n "${PUBLIC_IP}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -publicip=${PUBLIC_IP}"
fi

if [ -n "${PUBLIC_PORT}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -publicport=${PUBLIC_PORT}"
fi

if [ -n "${SERVER_NAME}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -servername=${SERVER_NAME}"
fi

if [ -n "${SERVER_PASSWORD}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -serverpassword=${SERVER_PASSWORD}"
fi

if [ -n "${ADMIN_PASSWORD}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -adminpassword=${ADMIN_PASSWORD}"
fi

if [ -n "${QUERY_PORT}" ]; then
    STARTCOMMAND="${STARTCOMMAND} -queryport=${QUERY_PORT}"
fi

if [ "${MULTITHREADING}" = true ]; then
    STARTCOMMAND="${STARTCOMMAND} -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
fi

cd /palworld || exit

printf "\e[0;32m*****CHECKING FOR EXISTING CONFIG*****\e[0m\n"

if [ ! -f /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini ]; then

    printf "\e[0;32m*****GENERATING CONFIG*****\e[0m\n"

    # Server will generate all ini files after first run.
    su steam -c "timeout --preserve-status 15s ./PalServer.sh 1> /dev/null "

    # Wait for shutdown
    sleep 5
    cp /palworld/DefaultPalWorldSettings.ini /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi

if [ -n "${RCON_ENABLED}" ]; then
    echo "RCON_ENABLED=${RCON_ENABLED}"
    sed -i "s/RCONEnabled=[a-zA-Z]*/RCONEnabled=$RCON_ENABLED/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${RCON_PORT}" ]; then
    echo "RCON_PORT=${RCON_PORT}"
    sed -i "s/RCONPort=[0-9]*/RCONPort=$RCON_PORT/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi

# Configure RCON settings
cat >~/.rcon-cli.yaml  <<EOL
host: localhost
port: ${RCON_PORT}
password: ${ADMIN_PASSWORD}
EOL

# Patch server binary

if [ "${PATCH_SERVER}" = true ]; then
    if [ ! -f /palworld/Pal/Binaries/Linux/PalServer-Linux-Test ]; then
        printf "\e[0;31m***** NO [PATCHED] SERVER: 当前服务端未安装或安装失败。 *****\e[0m\n"
        exit 1
    fi
    current_md5=$(md5sum /palworld/Pal/Binaries/Linux/PalServer-Linux-Test | awk '{print $1}')
    needpatch_md5=$(md5sum /home/steam/PalServer-Linux-Test | awk '{print $1}')
    expected_md5=$(cat /home/steam/md5.txt)

    # 判断 /palworld/Pal/Binaries/Linux/PalServer-Linux-Test 的 md5 值是否与 /home/steam/md5.txt 中的值相同
    if [ "$current_md5" = "$needpatch_md5" ]; then
        printf "\e[0;32m***** [PATCHED] SERVER: 当前服务端已修改。 *****\e[0m\n"
    else
        printf "\e[0;31m***** NO [PATCHED] SERVER: 当前服务端与修改后的 MD5 值不同。 *****\e[0m\n"
        if [ "$current_md5" = "$expected_md5" ]; then
            printf "\e[0;32m***** [PATCHING] SERVER: 当前原始文件与预期的 MD5 值相同。 *****\e[0m\n"
            cp -f /home/steam/PalServer-Linux-Test /palworld/Pal/Binaries/Linux/PalServer-Linux-Test
            chmod 755 /palworld/Pal/Binaries/Linux/PalServer-Linux-Test
            chown steam:steam /palworld/Pal/Binaries/Linux/PalServer-Linux-Test
            md5sum /palworld/Pal/Binaries/Linux/PalServer-Linux-Test
            echo "服务端修补完成。"
        else
            printf "\e[0;32m***** NO [PATCH] NEEDED: 当前源文件与预期的 MD5 值不同。 *****\e[0m\n"
        fi
    fi
    current_md5=$(md5sum /palworld/Pal/Binaries/Linux/PalServer-Linux-Test | awk '{print $1}')
    echo "$expected_md5 $current_md5 $needpatch_md5"
else
    printf "\e[0;32m***** NO [PATCH] NEEDED: 当前未启用服务端修补。 *****\e[0m\n"
fi


printf "\e[0;32m*****STARTING SERVER*****\e[0m\n"
echo "${STARTCOMMAND}"
su steam -c "${STARTCOMMAND}"
