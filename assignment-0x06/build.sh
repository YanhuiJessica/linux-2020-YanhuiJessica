#!/usr/bin/env bash

bash code/nopassh.sh || exit 1

remote='root@192.168.56.21'

echo "Setting up Proftpd environment..."
ssh "$remote" bash code/proftpd.sh || exit 1
echo "Proftpd environment build complete!"

echo "Setting up NFS environment..."
ssh "$remote" bash code/nfs-server.sh || echo "Failed to set up NFS server!"; exit 1
bash code/nfs-client.sh || echo "Failed to set up NFS client!"; exit 1
echo "NFS environment build complete!"

echo "Setting up DHCP server environment..."
ssh "$remote" bash code/dhcp-server.sh || exit 1
echo "DHCP server environment build complete!"

echo "Setting up DNS server environment..."
ssh "$remote" bash code/dns-server.sh || exit 1
echo "DNS server environment build complete!"

echo "Setting up Samba Linux environment..."
ssh "$remote" bash code/samba-linux.sh || exit 1
echo "Samba Linux environment build complete!"