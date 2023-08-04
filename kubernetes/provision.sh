#!/bin/bash

DIR=$(cd $(dirname $0) && pwd)
cd $DIR

# Provision VMs
terraform init
terraform apply -auto-approve
sleep 30

# Check if enable to login via ssh
vm_list=( \
    "k8s_master_1" \
    "k8s_master_2" \
    "k8s_worker_1" \
    "k8s_worker_2" \
)
for vm in "${vm_list[@]}"; do
    res=$(virsh domifaddr $vm)
    ipaddr=$(echo $res | sed "s/.*ipv4\ \(.*\)\/.*/\1/")
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ipaddr pwd
done