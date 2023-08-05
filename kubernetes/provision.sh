#!/bin/bash

DIR=$(cd $(dirname $0) && pwd)
cd $DIR

vm_list=( \
    "k8s_master_1" \
    "k8s_master_2" \
    "k8s_worker_1" \
    "k8s_worker_2" \
)

# Create user's cloud-init files
for i in "${!vm_list[@]}"; do
    vm="${vm_list[$i]}"
    cat <<EOF > network_config_$vm.cfg
version: 2
ethernets:
  eth0:
    dhcp4: no
    addresses: [192.168.1.20$(($i+1))/24]
    gateway4: 192.168.0.1
    nameservers:
      addresses: [8.8.8.8, 8.8.4.4]
EOF
done

# Create a bridge br0
sudo brctl addbr br0
sudo ip link set up dev br0
sudo ip addr add dev br0 192.168.1.1/24
sudo brctl addif br0 enp1s0
brctl show

# Provision VMs
terraform init
terraform apply -auto-approve
sleep 30

# Check if enable to login via ssh
ip_list=( \
    "192.168.1.201" \
    "192.168.1.202" \
    "192.168.1.203" \
    "192.168.1.204" \
)
for ip in "${ip_list[@]}"; do
    echo "Connecting $ip ..."
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip pwd
done