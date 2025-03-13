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

# Download and install SteamCMD
if [ ! -d ./steamcmd ]; then
    echo "SteamCMD not found. Installing..."
    mkdir -p ./steamcmd
    cd ./steamcmd
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
    cd /home/container
fi

## just in case someone removed the defaults.
if [ -z "${STEAM_USER}" ] || [ -z "${STEAM_PASS}" ]; then
    echo -e "Steam user or password or authcode is not set.\n"
else
    echo -e "Steam User set to ${STEAM_USER}"
    # Set auth if not set
    if [ -z "${STEAM_AUTH}" ]; then
        STEAM_AUTH=""
    fi

    ## if starting command is updategame or updateboth update the game
    if [ "${STARTUP}" == "updategame" ] || [ "${STARTUP}" == "updateboth" ]; then 
        echo -e "Checking for game updates and updating if necessary..."
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +@sSteamCmdForcePlatformType windows $(printf %s "+app_update 648800 -beta beta validate") +quit
    else
        echo -e "Not updating game as startup command is not set to updategame or updateboth. Starting Server"
    fi
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

EXECUTABLE="RaftDedicatedServer.exe"

# if starting command is updateserver or updateboth update the server
if [ "${STARTUP}" == "updateserver" ] || [ "${STARTUP}" == "updateboth" ]; then
    EXECUTABLE="RaftDedicatedServer.exe -update"
else
    echo -e "Not updating server as startup command is not set to updateserver or updateboth. Starting Server..."
fi

# Starting RDS itself
echo -e "#############################################\n# Starting Raft Dedicated Server...         #\n#############################################"
echo -e "  _____    _____     _____ \n |  __ \  |  __ \   / ____|\n | |__) | | |  | | | (___  \n |  _  /  | |  | |  \___ \ \n | | \ \  | |__| |  ____) |\n |_|  \_\ |_____/  |_____/ \n                           \n                           "



#/usr/bin/xvfb-run -a -l env WINEDLLOVERRIDES="wininet=native,builtin" wine64 ${EXECUTABLE} < /dev/stdin
#Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x24 &
#export DISPLAY=:0
#wine64 ${EXECUTABLE} < /dev/stdin

# Install socat if needed


# Start Xvfb
Xvfb :99 -screen 0 1024x768x24 &
export DISPLAY=:99

# Use socat to handle stdin/stdout
socat STDIN,raw,echo=0,escape=0x1d EXEC:"env WINEDLLOVERRIDES=wininet=native,builtin wine64 ${EXECUTABLE}",pty,ctty,setsid