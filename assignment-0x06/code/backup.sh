#!/usr/bin/env bash

# 用于文件备份
config=$1

if [[ ! -f "$config" ]]; then
    exit 0
fi

filenum=1
datetime=$(date +%Y%m%d)
extend="${file##*.}"
if [[ -n "$extend" ]]; then
    extend=".$extend"
fi
while [ -f "${config%.*}-$datetime-$filenum$extend" ]; do
    filenum=$((filenum+1))
done
echo "Backing up $2 config file to ${config%.*}-$datetime-$filenum$extend..."
cp "$config" "${config%.*}-$datetime-$filenum$extend" || echo "Failed to back up. Exiting..."; exit 1