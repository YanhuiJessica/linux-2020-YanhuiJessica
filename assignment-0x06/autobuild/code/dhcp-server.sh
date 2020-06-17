#!/usr/bin/env bash

if ! [[ $(command -v dhcpd) ]]; then
    echo "isc-dhcp-server is uninstalled. Installing..."
    apt install isc-dhcp-server -y || { echo "Failed to install isc-dhcp-server. Exiting..."; exit 1; }
fi

config=/etc/dhcp/dhcpd.conf
default_conf=/etc/default/isc-dhcp-server
netplan_conf=/etc/netplan/01-netcfg.yaml
adapter=enp0s9

bash "$CODE_PATH/backup.sh" "$config" 'dhcpd' || exit 1

cat > "$config" << EOF
default-lease-time 600;
max-lease-time 7200;
option domain-name-servers 192.168.233.1;

subnet 192.168.233.0 netmask 255.255.255.0 {
    range 192.168.233.50 192.168.233.150;
}
EOF

bash "$CODE_PATH/backup.sh" "$default_conf" 'isc-dhcp-server' || exit 1

cat > "$default_conf" << EOF
INTERFACESv4="$adapter"
EOF

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
      dhcp4: no
      addresses: [192.168.233.1/24]
EOF

netplan apply
service isc-dhcp-server restart