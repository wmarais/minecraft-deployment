#!/bin/bash

# This is the only thing that should be updated to download the right version of the server.
DOWNLOAD_LINK=https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar

# Should not need to tune anything below here.
INSTALL_DIR=/opt/minecraft-server
RUN_USER=minecraft
RUN_GROUP=${RUN_USER}

SERVICE_NAME=minecraft-server.service
SERVICE_PATH=/etc/systemd/system

# Create the installation directory.
mkdir -p ${INSTALL_DIR}

# Create a system user account for minecraft.
useradd --system --no-create-home ${RUN_USER}

# Copy the basic configuration files for minecraft.
cp ./minecraft-server/* ${INSTALL_DIR}

# Download the server executable.
cd ${INSTALL_DIR}
wget ${DOWNLOAD_LINK} 

# Allow the minecraft user to run minecraft and access the directories.
chown ${RUN_USER}:${RUN_GROUP} -R ${INSTALL_DIR}

# Install the service script
ln -s ${INSTALL_DIR}/${SERVICE_NAME} ${SERVICE_PATH}/${SERVICE_NAME}
chown root:root ${INSTALL_DIR}/${SERVICE_NAME}
chmod 660 ${INSTALL_DIR}/${SERVICE_NAME}
systemctl enable ${SERVICE_NAME}

