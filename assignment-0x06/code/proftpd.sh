#!/usr/bin/env bash

# 判断当前环境是否安装 proftpd
if ! [[ $(command -v proftpd) ]]; then
    echo "proftpd is uninstalled. Installing..."
    apt install proftpd -y || echo "Failed to install proftpd. Exiting..."; exit 1
fi

# 为匿名用户创建账户
echo anonftpass | ftpasswd --stdin --passwd --file=/etc/proftpd/ftpd.passwd \
--name=anonftp --uid=2333 --gid=2333 --home=/home/proftpd/anonftp/ --shell=/bin/false

# Create directory for anonymous
anon_path=/var/ftp/pub
if [[ ! -d "$anon_path" ]]; then
    mkdir -p "$anon_path"
fi
chown nobody:nogroup "$anon_path"
echo 'proftpd test file' > $anon_path/test.txt
if [[ ! -d "$anon_path/subdir" ]]; then
    mkdir -p "$anon_path/subdir"
fi

# 创建密码为 proftpuserpass 的虚拟用户 proftpuser
echo proftpuserpass | ftpasswd --stdin --passwd --file=/etc/proftpd/ftpd.passwd \
--name=proftpuser --uid=233 --gid=233 --home=/home/proftpd/proftpuser/ --shell=/bin/false

# Create an ftpd.group file
ftpasswd --group --name=proftpgroup --file=/etc/proftpd/ftpd.group \
--gid=233 --member proftpuser

# Create home for proftpuser
if [[ ! -d /home/proftpd/proftpuser ]]; then
    mkdir -p /home/proftpd/proftpuser
fi
chown -R proftpd:nogroup /home/proftpd

# 创建备份文件
config=/etc/proftpd/proftpd.conf
bash ./backup.sh "$config" 'proftpd' || exit 1

# 当前配置文件可能不是示例文件，所以选择直接写入覆盖
cp "$CONFIG_PATH/proftpd.conf" /etc/proftpd/proftpd.conf

service proftpd restart