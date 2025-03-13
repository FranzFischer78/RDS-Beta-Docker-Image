#!/bin/bash
cd /home/container

# Setup tty width so wine console output doesn't prematurely wrap
stty columns 250


# Information output
echo "Running on Debian $(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
wine --version

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

## just in case someone removed the defaults.
if [ -z "${STEAM_USER}" ] || [ -z "${STEAM_PASS}" ]; then
    echo -e "Steam user or password or authcode is not set.\n"
else
    echo -e "Steam User set to ${STEAM_USER}"
    # Set APPID
    SRCDS_APPID=648800
    # Set auth if not set
    if [ -z "${STEAM_AUTH}" ]; then
        STEAM_AUTH=""
    fi

    ## if auto_update is not set or to 1 update
    if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then 
        echo -e "Checking for Game Server updates and updating if necessary..."
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $(printf %s "-beta beta" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
    else
        echo -e "Not updating game server as auto update was set to 0. Starting Server"
    fi
fi

if [[ $XVFB == 1 ]]; then
        Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

# Install necessary to run packages
echo "First launch will throw some errors. Ignore them"

# Disable sound 
winetricks -q sound=disabled

# Create Wine prefix directory if necessary
mkdir -p $WINEPREFIX

if [ ! -f "$WINEPREFIX/mono.msi" ]; then
        echo "Installing mono"
        wget -q -O $WINEPREFIX/mono.msi https://dl.winehq.org/wine/wine-mono/9.1.0/wine-mono-9.1.0-x86.msi
fi

wine msiexec /i $WINEPREFIX/mono.msi /qn /quiet /norestart /log $WINEPREFIX/mono_install.log

# Replace Startup Variables
echo Starting Raft Dedicated Server...

#MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
#echo ":/home/container$ ${MODIFIED_STARTUP}"
#eval ${MODIFIED_STARTUP}
# Run the Server

/usr/bin/xvfb-run -a -l env WINEDLLOVERRIDES="wininet=native,builtin" wine64 "RaftDedicatedServer.exe"