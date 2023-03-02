###########################################################
# Dockerfile that builds a Conan Exiles Gameserver
###########################################################
FROM debian:bullseye-slim

LABEL maintainer="bert@lair.be"

################
# steamcmd     #
################
ENV STEAMCMDDIR /home/steam/steamcmd

# Install, update & upgrade packages
# Create user for the server
# This also creates the home directory we later need
# Create Directory for SteamCMD
# Download SteamCMD
# Extract and delete archive
RUN set -x \
    # Add i386 so we can install Wine downstream
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
               lib32stdc++6 \
               lib32gcc-s1 \
               wget \
               ca-certificates \
    && groupadd steam \
    && useradd -m steam -g steam \
    && su steam -c \
	  "mkdir -p ${STEAMCMDDIR} \
		 && cd ${STEAMCMDDIR} \
So		 && wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf -" \
    

###################
# No One Survived #
###################
ENV STEAMAPPID 2329680
ENV STEAMAPPDIR /home/steam/nos-dedicated
RUN sed -i -e "s/ main[[:space:]]*\$/ main contrib non-free/" /etc/apt/sources.list
# Install dependencies
RUN set -x \
    # Add WineHQ repository
    && apt-get install -y --no-install-recommends --no-install-suggests \
               curl \
               gnupg \
               locales \
               software-properties-common \
    && curl https://dl.winehq.org/wine-builds/winehq.key | apt-key add \
    && apt-add-repository 'deb http://dl.winehq.org/wine-builds/debian/ bullseye main' \

# Install locale
RUN sed --in-place '/en_US.UTF-8/s/^#//' -i /etc/locale.gen \
    && /usr/sbin/locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8  

# Install Wine
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
               winbind \
               libwine \
               libwine:i386 \
               fonts-wine \
               winehq-stable \
               xauth \
			   xvfb \
    # Clean TMP, apt-get cache and other stuff to make the image smaller
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
               
# Run Steamcmd and install the No One Survived Dedicated Server              
RUN set -x \
    && su steam -c \
          "${STEAMCMDDIR}/steamcmd.sh \
          +@sSteamCmdForcePlatformType windows \
          +force_install_dir ${STEAMAPPDIR} \
          +login anonymous \
          +app_update ${STEAMAPPID} validate \
          +quit"

WORKDIR $STEAMAPPDIR

VOLUME $STEAMAPPDIR

# Parameters for the Conan process
RUN	    wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
        && chmod +x /usr/sbin/winetricks
ENV 	NOS_ARGS -log -nosteam -server
ENV     HOME=${STEAMAPPDIR}
ENV     WINEPREFIX=${STEAMAPPDIR}/.wine
ENV     WINEDLLOVERRIDES="mscoree,mshtml="
ENV     DISPLAY=:0
ENV     DISPLAY_WIDTH=1024
ENV     DISPLAY_HEIGHT=768
ENV     DISPLAY_DEPTH=16
ENV     AUTO_UPDATE=1
ENV     XVFB=1

# Set Entrypoint
# 1. Update server
# 2. Start the server
COPY ./startup.sh /root/startup.sh
ENTRYPOINT ["/root/startup.sh"]

EXPOSE 27014/udp 7767/udp 