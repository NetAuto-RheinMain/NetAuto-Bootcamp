#!/bin/bash

echo "--- Start Bootcamp Setup ---"

# 1. Install Containerlab 
echo "Install Containerlab..."
bash -c "$(curl -sL https://get.containerlab.dev)"

# 2. Pull SRLinux Image
echo "Pulling Nokia SRLinux..."
docker pull ghcr.io/nokia/srlinux:latest

# 3. Install Python Requirements  (if there are any)
if [ -f "requirements.txt" ]; then
    echo "Installiere Python Dependencies..."
    pip3 install -r requirements.txt
fi

# 4. Final Message
echo "----------------------------------------------------------------"
echo "SETUP COMPELTED!"
echo "SRLinux Image is available."
echo "Comment for Arista Image: Please load the cEOS-Image manually:"
echo "docker import cEOS64-lab-4.30.0F.tar.xz ceos:4.30.0F"
echo "----------------------------------------------------------------"
