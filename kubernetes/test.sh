#!/bin/bash

# Check if enable to login via ssh
ip_list=( \
    "192.168.8.201" \
    "192.168.8.202" \
    "192.168.8.203" \
    "192.168.8.204" \
)
for ip in "${ip_list[@]}"; do
    echo "Connecting $ip ..."
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip pwd
done
