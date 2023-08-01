#!/usr/bin/env python3
import subprocess
import os
import shutil
import time

# manually destoroy
if os.path.exists(".terraform"):
    shutil.rmtree(".terraform")
if os.path.exists("terraform.tfstate"):
    os.remove("terraform.tfstate")


# remove vm
vm_list = [
    "k8s_master_1",
    "k8s_master_2",
    "k8s_worker_1",
    "k8s_worker_2",
]

for vm_name in vm_list:
    # remove images
    subprocess.run(["virsh", "destroy", vm_name])
    subprocess.run(["virsh", "undefine", vm_name])

# remove networks
nw_list = [
    "k8s_network"
]

for net in nw_list:
    subprocess.run(["virsh", "net-destroy", net])
    subprocess.run(["virsh", "net-undefine", net])

# remove images from pool
image_list = [
    "/var/lib/libvirt/images/commoninit.iso",
    "/var/lib/libvirt/images/k8s_master_1.qcow2",
    "/var/lib/libvirt/images/k8s_master_2.qcow2",
    "/var/lib/libvirt/images/k8s_worker_1.qcow2",
    "/var/lib/libvirt/images/k8s_worker_2.qcow2",
]

for image in image_list:
    subprocess.run(["sudo", "rm", "-rf", image])

# terraform
subprocess.run(["terraform", "init"])
subprocess.run(["terraform", "apply", "-auto-approve"])
time.sleep(30)
for vm_name in vm_list:
    res = subprocess.run(["virsh", "domifaddr", vm_name], capture_output=True)
    addr_info = res.stdout.split(b"-\n")[1]
    ipaddr = addr_info.split()[3].decode('utf-8')[:-3]
    print(ipaddr)

    subprocess.run([
        "ssh",
        "-o", "UserKnownHostsFile=/dev/null",
        "-o", "StrictHostKeyChecking=no",
        f"root@{ipaddr}",
        "pwd"
    ])