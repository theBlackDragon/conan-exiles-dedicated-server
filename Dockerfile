###########################################################
# Dockerfile that builds a Conan Exiles Gameserver
###########################################################
FROM bgeens/steamcmd-root:0.1

LABEL maintainer="bert@lair.be"

ENV STEAMAPPID 443030
ENV STEAMAPPDIR /home/steam/conan-dedicated

# Install dependencies
RUN set -x \
    # Add WineHQ repository
    dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
               curl \
               gnupg \
               locales \
               software-properties-common \
    && curl https://dl.winehq.org/wine-builds/winehq.key | apt-key add \
    && apt-add-repository 'deb http://dl.winehq.org/wine-builds/debian/ stretch main' \
    && apt-get remove --purge -y \
               curl \
    && apt-get clean autoclean \
    && apt-get autoremove -y

# Install locale
RUN sed --in-place '/en_US.UTF-8/s/^#//' -i /etc/locale.gen \
    && /usr/sbin/locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8  

# Install Wine
RUN set -x \
    # dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
               # screen \
               wine \
               wine32 \
               wine64 \
               libwine \
               libwine:i386 \
               fonts-wine \
               wine-stable \
               # winehq-stable \
               xauth \
               xvfb
               
# Run Steamcmd and install the Conan Exiles Dedicated Server              
RUN set -x \
    && su steam -c \
          "${STEAMCMDDIR}/steamcmd.sh \
          +@sSteamCmdForcePlatformType windows \
          +login anonymous \
          +force_install_dir ${STEAMAPPDIR} \
          +app_update ${STEAMAPPID} validate \
          +quit"

WORKDIR $STEAMAPPDIR

VOLUME $STEAMAPPDIR

# Set Entrypoint
# 1. Update server
# 2. Start the server
COPY ./startup.sh /root/startup.sh
ENTRYPOINT ["/root/startup.sh"]

EXPOSE 27015/udp 7777/udp 7778/udp
