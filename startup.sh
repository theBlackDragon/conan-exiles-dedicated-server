#!/bin/bash

PUID=${PUID:-911}
PGID=${PGID:-911}

groupmod -o -g "$PGID" steam
usermod -o -u "$PUID" steam

echo "
-------------------------------------
GID/UID
-------------------------------------
User uid:    $(id -u steam)
User gid:    $(id -g steam)
-------------------------------------
"
chown steam:steam -R /home/steam
echo "
-------------------------------------
Updating application
-------------------------------------
"
set -x
su steam -c "${STEAMCMDDIR}/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir ${STEAMAPPDIR} +login anonymous +app_update ${STEAMAPPID} validate +quit"

winetricks -q dotnet48 d3dcompiler_47


STEAMSERVERID=2329680


echo "
-------------------------------------
Starting server
-------------------------------------
"
su steam -c  "xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine ${STEAMAPPDIR}/WRSHServer.exe -log -nosteam -server"
# su steam -c  "xvfb-run --auto-servernum wine ${STEAMAPPDIR}/WRSHServer.exe ${NOS_ARGS}"
