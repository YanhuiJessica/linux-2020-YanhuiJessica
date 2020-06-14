#!/usr/bin/env bash

if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
    # 创建创建公钥-私钥对
    ssh-keygen -f ~/.ssh/id_rsa -N ""
fi

# 将 AC-Server 的公钥复制到 AC-Target
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.56.21

# 测试是否成功
timeout 5 ssh root@192.168.56.21 echo "SSH has passwordless access!"
if [[ $? -ne 0 ]]; then
    echo "SSH has no passwordless access!. Exiting..."
    exit 1
fi