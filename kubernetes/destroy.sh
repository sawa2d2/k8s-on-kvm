#!/bin/bash

DIR=$(cd $(dirname $0) && pwd)
cd $DIR

# Remove terraform files
terraform_files=( \
    ".terraform" \
    "terraform.tfstate" \
    ".terraform.lock.hcl" \
)
for f in "${terraform_files[@]}"; do
    rm -rf $f
done

# Remove VMs
vm_list=( \
    "k8s_master_1" \
    "k8s_master_2" \
    "k8s_worker_1" \
    "k8s_worker_2" \
)
for vm in "${vm_list[@]}"; do
    virsh destroy $vm
    virsh undefine $vm
done

# Remove networks
nw_list=( \
    "k8snet" \
)
for nw in "${nw_list[@]}"; do
    virsh net-destroy $nw
    virsh net-undefine $nw
done

# Remove images from the default pool
image_list=( \
    "/var/lib/libvirt/images/commoninit_k8s_master_1.iso" \
    "/var/lib/libvirt/images/commoninit_k8s_master_2.iso" \
    "/var/lib/libvirt/images/commoninit_k8s_worker_1.iso" \
    "/var/lib/libvirt/images/commoninit_k8s_worker_2.iso" \
    "/var/lib/libvirt/images/k8s_master_1.qcow2" \
    "/var/lib/libvirt/images/k8s_master_2.qcow2" \
    "/var/lib/libvirt/images/k8s_worker_1.qcow2" \
    "/var/lib/libvirt/images/k8s_worker_2.qcow2" \
)
for image in "${image_list[@]}"; do
    sudo rm -rf $image
done
