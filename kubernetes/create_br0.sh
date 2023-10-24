#!/bin/bash

# Check the network interface of the host
HOST_IP=192.168.8.10
GATEWAY=192.168.8.1
DNS=192.168.8.1

nwif=$(ip a | grep $HOST_IP | awk '{ print $8}')
echo "The network interface of the host is $nwif."

# Create a temp bridge br0 if not exists

if [[ $(nmcli | grep -E '^br0\s+' > /dev/null 2>&1; echo $?) ]]; then
  echo "br0 is already exists."
else
  echo "Creating br0..."
  nmcli con add type bridge ifname br0
fi

nmcli connection modify bridge-br0 \
ipv4.method manual \
ipv4.addresses "$HOST_IP/24" \
ipv4.gateway "$GATEWAY" \
ipv4.dns $DNS

nmcli connection add type bridge-slave ifname $nwif master bridge-br0

nmcli connection delete $nwif
