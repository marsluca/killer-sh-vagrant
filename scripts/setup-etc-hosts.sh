#!/bin/bash
set -ex

sed -i -e "s/^.*${HOSTNAME}.*/${1} ${HOSTNAME} ${HOSTNAME}.local/" /etc/hosts

echo "Forcing time synchronization..."
timedatectl set-ntp true
systemctl restart systemd-timesyncd

echo "Waiting for time synchronization to complete..."
timeout 60 bash -c 'while ! timedatectl timesync-status | grep -E -q "Packet count: [1-9]"; do sleep 1; done' || true

echo "Writing corrected time to hardware clock..."
apt-get update -qq
apt-get install -y -qq util-linux-extra > /dev/null 2>&1
hwclock --systohc --utc
