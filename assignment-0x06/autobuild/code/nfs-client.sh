#!/usr/bin/env bash

sudo apt install nfs-common -y || { echo "Failed to install nfs-common. Exiting..."; exit 1; }

ro=/nfs/general_read
rw=/nfs/general_rw
nrs=/nfs/no_rtsquash

if [[ ! -d "$ro" ]]; then
    sudo mkdir -p "$ro"
fi

if [[ ! -d "$rw" ]]; then
    sudo mkdir -p "$rw"
fi

if [[ ! -d "$nrs" ]]; then
    sudo mkdir -p "$nrs"
fi

read_only=/var/nfs/general_read
read_write=/var/nfs/general_rw
no_root_squash=/var/nfs/no_rtsquash

sudo mount "$TARGET_IP:$read_only" "$ro"
sudo mount "$TARGET_IP:$read_write" "$rw"
sudo mount "$TARGET_IP:$no_root_squash" "$nrs"