#!/usr/bin/env bash

apt install nfs-kernel-server -y || echo "Failed to install nfs-kernel-server. Exiting..."; exit 1

read_only=/var/nfs/general_read
read_write=/var/nfs/general_rw

if [[ ! -d "$read_only" ]]; then
    mkdir -p "$read_only"
fi
chown nobody:nogroup "$read_only"

if [[ ! -d "$read_write" ]]; then
    mkdir -p "$read_write"
fi
chown nobody:nogroup "$read_write"

# 备份文件
config=/etc/exports
bash ./backup.sh "$config" 'nfs-kernel-server' || exit 1

cp ../config/nfs-server.conf /etc/exports

systemctl restart nfs-kernel-server