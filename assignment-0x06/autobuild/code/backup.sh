#!/usr/bin/env bash

# 用于文件备份
config=$1

if [[ ! -f "$config" ]]; then
    exit 0
fi

filenum=1
datetime=$(date +%Y%m%d)
filename="${config%.*}"
extend="${config##*.}"
if [[ "$filename" == "$extend" ]]; then
    extend=""
else
    extend=".$extend"
fi
while [ -f "$filename-$datetime-$filenum$extend" ]; do
    filenum=$((filenum+1))
done
echo "Backing up $2 config file to $filename-$datetime-$filenum$extend..."
cp "$config" "$filename-$datetime-$filenum$extend" || { echo "Failed to back up. Exiting..."; exit 1; }