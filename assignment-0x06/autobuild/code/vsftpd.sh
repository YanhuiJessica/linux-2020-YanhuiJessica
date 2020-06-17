#!/usr/bin/env bash

# 判断当前环境是否安装 vsftpd
if ! [[ $(command -v vsftpd) ]]; then
    echo "vsftpd is uninstalled. Installing..."
    sudo apt install vsftpd -y || echo "Failed to install vsftpd. Exiting..."; exit 1
fi

# Create directory for anonymous
anon_path=/var/ftp/pub
if [[ ! -d "$anon_path" ]]; then
    sudo mkdir -p "$anon_path"
fi
sudo chown nobody:nogroup "$anon_path"
sudo bash -c "echo 'vsftpd test file' > $anon_path/test.txt"

# Create the virtual users database
# Create a user called "vftpuser" with password "vftpuserpass"
cat > /tmp/vusers.txt << EOF
vftpuser
vftpuserpass
EOF
if [[ ! -d /etc/ftp ]]; then
    sudo mkdir -p /etc/ftp
fi

if ! [[ $(command -v db_load) ]]; then
    echo "db_load is uninstalled. Installing..."
    sudo apt install db_util -y || echo "Failed to install db_load. Exiting..."; exit 1
fi
sudo db_load -T -t hash -f /tmp/vusers.txt /etc/ftp/vsftpd-virtual-user.db
# make it not global readable
sudo chmod 600 /etc/ftp/vsftpd-virtual-user.db
rm /tmp/vusers.txt

datetime=$(date +%Y%m%d)
if [[ -f /etc/pam.d/vsftpd.virtual ]]; then
    filenum=1
    while [ -f "/etc/pam.d/vsftpd-$datetime-$filenum.virtual" ]; do
        filenum=$((filenum+1))
    done
    echo "Backing up vsftpd.virtual to /etc/pam.d/vsftpd-$datetime-$filenum.virtual..."
    cp /etc/pam.d/vsftpd.virtual "/etc/pam.d/vsftpd-$datetime-$filenum.virtual" || echo "Failed to back up. Exiting..."; exit 1
fi

sudo bash -c "cat > /etc/pam.d/vsftpd.virtual" << EOF
#%PAM-1.0
auth       required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
account    required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
account    required     pam_access.so
session    required     pam_loginuid.so
EOF

if [[ ! -d /home/vftp/vftpuser ]]; then
    sudo mkdir -p /home/vftp/vftpuser
fi
sudo chown -R ftp:ftp /home/vftp

if [[ -f /etc/vsftpd.userlist ]]; then
    filenum=1
    while [ -f "/etc/vsftpd-$datetime-$filenum.userlist" ]; do
        filenum=$((filenum+1))
    done
    echo "Backing up vsftpd.userlist to /etc/vsftpd-$datetime-$filenum.userlist..."
    cp /etc/vsftpd.userlist "/etc/vsftpd-$datetime-$filenum.userlist" ||  echo "Failed to back up. Exiting..."; exit 1
fi

sudo bash -c "cat > /etc/vsftpd.userlist" << EOF
anonymous
vftpuser
EOF

# 创建备份文件
config=/etc/vsftpd.conf
filenum=1
while [ -f "${config%.*}-$datetime-$filenum.config" ]; do
    filenum=$((filenum+1))
done
echo "Backing up vsftpd config file to ${config%.*}-$datetime-$filenum.config..."
sudo cp "$config" "${config%.*}-$datetime-$filenum.config" || echo "Failed to back up. Exiting..."; exit 1

# 当前配置文件可能不是示例文件，所以选择直接写入覆盖
sudo bash -c "cat > $config" << EOF
listen=NO
listen_ipv6=YES

# Disabling this option enables vsftpd to run with slightly less privilege.
connect_from_port_20=YES

# Allow anonymous FTP
anonymous_enable=YES
no_anon_password=YES
anon_root=$anon_path

# Enable for any non-anonymous login to work, including virtual users
local_enable=YES
virtual_use_local_privs=YES
write_enable=YES
force_local_data_ssl=NO

# Activates virtual users
guest_enable=YES

# Set the name of the PAM service vsftpd will use
pam_service_name=vsftpd.virtual

# Automatically generate a home directory for each virtual user, based on a template.
# For example, if the home directory of the real user specified via guest_username is
# /home/virtual/\$USER, and user_sub_token is set to \$USER, then when virtual user vivek
# logs in, he will end up (usually chroot()'ed) in the directory /home/virtual/vivek.
# This option also takes affect if local_root contains user_sub_token.
user_sub_token=\$USER
local_root=/home/vftp/\$USER

# Chroot user and lock down to their home dirs
chroot_local_user=YES
allow_writeable_chroot=YES

use_localtime=YES
secure_chroot_dir=/var/run/vsftpd/empty

# username whitelist
userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd.userlist
EOF