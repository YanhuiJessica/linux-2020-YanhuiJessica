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

cat > /etc/exports << EOF
/var/nfs/general_read   $WORKER_IP(ro,sync,no_subtree_check)
/var/nfs/general_rw     $WORKER_IP(rw,sync,no_subtree_check)
EOF

systemctl restart nfs-kernel-server