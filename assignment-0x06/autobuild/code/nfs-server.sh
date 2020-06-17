#!/usr/bin/env bash

apt install nfs-kernel-server -y || { echo "Failed to install nfs-kernel-server. Exiting..."; exit 1; }

read_only=/var/nfs/general_read
read_write=/var/nfs/general_rw
no_root_squash=/var/nfs/no_rtsquash

if [[ ! -d "$read_only" ]]; then
    mkdir -p "$read_only"
fi
chown nobody:nogroup "$read_only"

if [[ ! -d "$read_write" ]]; then
    mkdir -p "$read_write"
fi
chown nobody:nogroup "$read_write"

if [[ ! -d "$no_root_squash" ]]; then
    mkdir -p "$no_root_squash"
fi
chown nobody:nogroup "$no_root_squash"

# 备份文件
config=/etc/exports
bash "$CODE_PATH/backup.sh" "$config" 'nfs-kernel-server' || exit 1

cat > /etc/exports << EOF
/var/nfs/general_read   $WORKER_IP(ro,sync,no_subtree_check)
/var/nfs/general_rw     $WORKER_IP(rw,sync,no_subtree_check)
/var/nfs/no_rtsquash    $WORKER_IP(rw,sync,no_root_squash,no_subtree_check)
EOF

systemctl restart nfs-kernel-server