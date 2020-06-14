#!/usr/bin/env bash

if ! [[ $(command -v samba) ]]; then
    echo "samba is uninstalled. Installing..."
    apt install samba -y || echo "Failed to install samba. Exiting..."; exit 1
fi

# 创建匿名用户可访问目录
anon_path=/var/sambashare/pub
if [[ ! -d "$anon_path" ]]; then
    mkdir -p "$anon_path"
fi
chown nobody:nogroup "$anon_path"
chmod 2775 "$auth_path"

# Samba 用户
useradd -M -s /sbin/nologin smbuser
# Samba account password
smbpasswd -a smbuser

groupadd smbgroup
usermod -a -G smbgroup smbuser

# 虚拟用户可访问目录
auth_path=/var/sambashare/private
if [[ ! -d "$auth_path" ]]; then
    mkdir -p "$auth_path"
fi
chown smbuser:smbuser "$auth_path"
chmod 2770 "$auth_path"

config=/etc/samba/smb.conf
bash ./backup.sh "$config" 'samba' || exit 1

cp ../config/smb.conf "$config"
service smbd restart