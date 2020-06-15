#!/usr/bin/env bash

bash setenv.sh
remote="$TARGET_USER@$TARGET_IP"
ssh "$remote" bash setenv.sh

bash "$CODE_PATH/nopassh.sh" || exit 1

echo "Setting up Proftpd environment..."
ssh "$remote" bash "$CODE_PATH/proftpd.sh" || exit 1
echo "Proftpd environment build complete!"

echo "Setting up NFS environment..."
ssh "$remote" bash "$CODE_PATH/nfs-server.sh" || echo "Failed to set up NFS server!"; exit 1
bash "$CODE_PATH/nfs-client.sh" || echo "Failed to set up NFS client!"; exit 1
echo "NFS environment build complete!"

echo "Setting up DHCP server environment..."
ssh "$remote" bash "$CODE_PATH/dhcp-server.sh" || exit 1
echo "DHCP server environment build complete!"

echo "Setting up DNS server environment..."
ssh "$remote" bash "$CODE_PATH/dns-server.sh" || exit 1
echo "DNS server environment build complete!"

echo "Setting up Samba server environment..."
ssh "$remote" bash "$CODE_PATH/samba-server.sh" || exit 1
echo "Samba server environment build complete!"

echo "Finished!"