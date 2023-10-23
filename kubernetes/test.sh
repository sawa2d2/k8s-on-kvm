#!/bin/bash

# Check if enable to login via ssh
ip_list=($(./generate_inventory.py | jq --raw-output '._meta.hostvars[].ip' | xargs))
for ip in "${ip_list[@]}"; do
    echo "Connecting $ip ..."
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip pwd
done
