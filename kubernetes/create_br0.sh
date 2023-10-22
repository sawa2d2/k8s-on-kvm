#!/bin/bash

# Check the network interface of the host
HOST_IP=192.168.8.12
NWIF=$(ip a | grep $HOST_IP | awk '{ print $8}')
echo "The network interface of the host is $NWIF."

# Create a temp bridge br0 if not exists

if [[ $(brctl show | grep -E '^br0\s+' > /dev/null 2>&1; echo $?) ]]; then
  echo "br0 is already exists."
else
  echo "Creating br0..."
  sudo brctl addbr br0
fi
sudo ip link set up dev br0
sudo ip addr add dev br0 192.168.8.8/24
echo "Adding $NWIF to br0..."
sudo brctl addif br0 $NWIF
brctl show