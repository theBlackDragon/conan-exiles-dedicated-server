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
Setting up wine
-------------------------------------
"
winetricks -q dotnet48 d3dcompiler_47 vcrun2015 allfonts



        if [ ! -f "$WINEPREFIX/gecko_x86.msi" ]; then
                wget -q -O $WINEPREFIX/gecko_x86.msi http://dl.winehq.org/wine/wine-gecko/2.47.3/wine_gecko-2.47.3-x86.msi
        fi

        if [ ! -f "$WINEPREFIX/gecko_x86_64.msi" ]; then
                wget -q -O $WINEPREFIX/gecko_x86_64.msi http://dl.winehq.org/wine/wine-gecko/2.47.3/wine_gecko-2.47.3-x86_64.msi
        fi

        wine msiexec /i $WINEPREFIX/gecko_x86.msi /qn /quiet /norestart /log $WINEPREFIX/gecko_x86_install.log
        wine msiexec /i $WINEPREFIX/gecko_x86_64.msi /qn /quiet /norestart /log $WINEPREFIX/gecko_x86_64_install.log
        
           if [ ! -f "$WINEPREFIX/mono.msi" ]; then
                wget -q -O $WINEPREFIX/mono.msi https://dl.winehq.org/wine/wine-mono/7.4.0/wine-mono-7.4.0-x86.msi
        fi

        wine msiexec /i $WINEPREFIX/mono.msi /qn /quiet /norestart /log $WINEPREFIX/mono_install.log


echo "
-------------------------------------
Updating application
-------------------------------------
"
set -x
su steam -c "${STEAMCMDDIR}/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir ${STEAMAPPDIR} +login anonymous +app_update ${STEAMAPPID} validate +quit"

STEAMSERVERID=2329680


echo "
-------------------------------------
Starting server
-------------------------------------
"
#su steam -c  "xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine ${STEAMAPPDIR}/WRSHServer.exe -log -nosteam -server"
su steam -c  "xvfb-run --auto-servernum wine ${STEAMAPPDIR}/WRSHServer.exe ${NOS_ARGS}"
