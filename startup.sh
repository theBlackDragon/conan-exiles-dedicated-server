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

echo "
------------------------------------
Updating mods
------------------------------------
"
STEAMSERVERID=440900
GAMEMODDIR=${STEAMAPPDIR}/ConanSandbox/Mods
GAMEMODLIST=${GAMEMODDIR}/modlist.txt

if [ ! -f ${STEAMAPPDIR}/modlist.txt ]; then
    echo "No modlist, creating empty ${STEAMAPPDIR}/modlist.txt"
    touch ${STEAMAPPDIR}/modlist.txt
fi

# Clear server modlist so we don't end up with duplicates
echo "" > ${GAMEMODLIST}
MODS=$(awk '{print $1}' ${STEAMAPPDIR}/modlist.txt)

MODCMD="${STEAMCMDDIR}/steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous"
for MODID in ${MODS}
do
    echo "Adding $MODID to update list..."
    MODCMD="${MODCMD}  +workshop_download_item ${STEAMSERVERID} ${MODID}"
done
MODCMD="${MODCMD} +quit"
su steam -c "${MODCMD}"

echo "Linking mods..."
mkdir -p ${GAMEMODDIR}
for MODID in ${MODS}
do
    echo "Linking $MODID..."
    MODDIR=/home/steam/Steam/steamapps/workshop/content/${STEAMSERVERID}/${MODID}/
    find "${MODDIR}" -iname '*.pak' >> ${GAMEMODLIST}
done


echo "
-------------------------------------
Starting server
-------------------------------------
"
# su steam -c  "xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine ${STEAMAPPDIR}/ConanSandboxServer.exe -log -nosteam"
su steam -c  "xvfb-run --auto-servernum wine64 ${STEAMAPPDIR}/ConanSandboxServer.exe ${CONAN_ARGS}"
