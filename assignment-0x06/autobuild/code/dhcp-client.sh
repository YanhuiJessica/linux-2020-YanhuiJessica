#!/usr/bin/env bash

netplan_conf=/etc/netplan/01-netcfg.yaml

bash "$CODE_PATH/backup.sh" "$netplan_conf" 'netplan' || exit 1
cat > "$netplan_conf" << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: yes
      dhcp6: yes
    enp0s8:
      dhcp4: yes
      dhcp6: yes
      dhcp-identifier: mac
    enp0s9:
      dhcp4: yes
EOF

netplan apply