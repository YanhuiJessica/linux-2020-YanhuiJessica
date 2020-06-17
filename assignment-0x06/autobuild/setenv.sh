#!/usr/bin/env bash

if grep -q 'CODE_PATH' /etc/environment
then
    cp /etc/environment.orig /etc/environment
else
    cp /etc/environment /etc/environment.orig
fi

cur_path=$(pwd)
cat >> /etc/environment << EOF
export CODE_PATH="$cur_path/autobuild/code"
export CONFIG_PATH="$cur_path/autobuild/config"
export TARGET_IP=192.168.56.21
export TARGET_USER=root
export WORKER_IP=192.168.56.13
EOF