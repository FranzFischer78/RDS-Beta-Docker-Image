#!/bin/bash
# The wine generic server installer
# This will just pull a download link and unpack it in directory if specified.

apt update -y
apt install -y curl file unzip

if [ ! -d /mnt/server ]; then
    mkdir -p /mnt/server/
fi

cd /mnt/server/

# if an install dir is set then make it and change to it.
if [ ! -z ${INSTALL_DIR} ]; then
    mkdir -p ${INSTALL_DIR}
    cd ${INSTALL_DIR}
fi

# validate server link
if [ ! -z "${DOWNLOAD_URL}" ]; then 
    if curl --output /dev/null --silent --head --fail ${DOWNLOAD_URL}; then
        echo -e "link is valid. setting download link to ${DOWNLOAD_URL}"
        DOWNLOAD_LINK=${DOWNLOAD_URL}
    else        
        echo -e "link is invalid closing out"
        exit 2
    fi
fi

curl -sSL ${DOWNLOAD_LINK} -o ${DOWNLOAD_LINK##*/}

# unpack server files
FILETYPE=$(file -F ',' ${DOWNLOAD_LINK##*/} | cut -d',' -f2 | cut -d' ' -f2)

if [ "$FILETYPE" == "gzip" ]; then
    tar xzvf ${DOWNLOAD_LINK##*/}
elif [ "$FILETYPE" == "Zip" ]; then
    unzip ${DOWNLOAD_LINK##*/}
elif [ "$FILETYPE" == "XZ" ]; then
    tar xvf ${DOWNLOAD_LINK##*/}
else
    echo -e "unknown filetype. Exiting"
    exit 2 
fi

## install end
echo "-----------------------------------------"
echo "Installation completed..."
echo "-----------------------------------------"