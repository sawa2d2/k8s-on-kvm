#!/bin/bash

HOST_IP=192.168.8.10
CIDR=24
GATEWAY=192.168.8.1
DNS=192.168.8.1

nwif=$(ip a | grep $HOST_IP | awk '{ print $8}')

if [[ $nwif == 'br0' ]]; then
  echo "Nothing to do: bridge \"$nwif\" is already exists."
  echo "--------"
  nmcli connection show
  exit 0
elif [[ $nwif == '' ]]; then
  echo "Error: Exsisting network interface not found which has the address $HOST_IP/$CIDR."
  exit 1
fi

echo "Creating br0..."
nmcli con add type bridge ifname br0
nmcli connection show

nmcli connection modify bridge-br0 \
ipv4.method manual \
ipv4.addresses "$HOST_IP/$CIDR" \
ipv4.gateway "$GATEWAY" \
ipv4.dns $DNS

nmcli connection add type bridge-slave ifname $nwif master bridge-br0

nmcli connection delete $nwif
