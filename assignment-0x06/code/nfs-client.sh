#!/usr/bin/env bash

sudo apt install nfs-common -y || echo "Failed to install nfs-common. Exiting..."; exit 1

ro=/nfs/general_read
rw=/nfs/general_rw

if [[ ! -d "$ro" ]]; then
    sudo mkdir -p "$ro"
fi

if [[ ! -d "$rw" ]]; then
    sudo mkdir -p "$rw"
fi

read_only=/var/nfs/general_read
read_write=/var/nfs/general_rw
srv_ip=192.168.56.21

sudo mount "$srv_ip:$read_only" "$ro"
sudo mount "$srv_ip:$read_write" "$rw"