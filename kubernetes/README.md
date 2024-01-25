# How to create a Kubernetes cluster on KVM with Terraform + Kubespray

Here is a sample code of this article [Terraform + Kubespray で KVM 上に Kubernetes クラスタを構築 - Qiita](https://qiita.com/sawa2d2/items/c592dcbd958f69441068).

## Summary

Here explains how to build a Kubernetes cluster on KVM using Terraform + Kubespray according to the general steps:

1. Create VMs using Terraform.
1. From the generated `terraform.tfstate` in step 1., extract inventory information using a script (Dynamic Inventory).
1. Give the inventory information from step 2. and Kubespray's playbooks to Ansible to create a Kubernetes cluster.

![dynamic_inventory](./images/dynamic_inventory.drawio.png)

The VM configuration in this repository is as shown in the diagram below:

![Network architecture](./images/network_architecture.drawio.png)

## Prerequisite
- Terraform
- Container engine (docker, podman, nerdctl, etc.)
- KVM Packages
  - qemu-kvm
  - libvirt
- nmcli
- jq
- yq

## Setup

Clone this repo:
```
$ git clone https://github.com/sawa2d2/k8s-on-kvm.git
$ cd k8s-on-kvm/kubernetes
```

Create virtual bridge `br0` as follow steps:
```
# Settings
HOST_IP=192.168.8.10
CIDR=24
GATEWAY=192.168.8.1
DNS=192.168.8.1
NWIF=enp1s0
CON_NAME="Wired Network 1"

# Create br0
nmcli connection add type bridge ifname br0

# Set br0 same settings of enp1s0
nmcli connection modify bridge-br0 \
  ipv4.method manual \
  ipv4.addresses "$HOST_IP/$CIDR" \
  ipv4.gateway "$GATEWAY" \
  ipv4.dns $DNS

# Connect enp1s0 to br0
nmcli connection add type bridge-slave ifname $NWIF master bridge-br0
# Delete the existing network interface of enp1s0
nmcli connection delete $CON_NAME

# Enable br0
nmcli connection up bridge-br0
```

It illustrates a change from 'Before' to 'After' as demonstrated in the diagram below:
![dynamic_inventory](./images/network-diff.drawio.png)

Check if the default pool of libvirt `/var/lib/libvirt/images/` exists:
```
$ virsh pool-list --all
 Name      State    Autostart
-------------------------------
 default   active   yes
```

If it does not exist, create it:
```
$ virsh pool-define /dev/stdin <<EOF
<pool type='dir'>
  <name>default</name>
  <target>
    <path>/var/lib/libvirt/images</path>
  </target>
</pool>
EOF

$ virsh pool-start default
$ virsh pool-autostart default
```

Download a qcow2 image of base OS (e.g. Rocky Linux 9) to the default pool:
```
$ sudo curl -L -o /var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2 https://download.rockylinux.org/pub/rocky/9.2/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2
```

Edit `cloud_init.cfg` to set your ssh public key:
```
#cloud-config
users:
  - name: root
    ssh-authorized-keys:
      - "<YOUR_SSH_KEY>"
...
```

## Provisioning VMs
Copy [`sample/three-nodes/main.tf`](./sample/three-nodes/main.tf) to your project root.

Then run the following to provision VMs:

```
$ terraform init
$ terraform apply -auto-approve
```

### Create a Kubernetes cluster 
Copy inventory files:
```
$ cp -rf .terraform/modules/kubernetes/kubernetes/inventory .
```

Run a kubespray container and execute Ansible playbook:
```
$ docker run --rm -it \
  --mount type=bind,source="$(pwd)"/inventory,dst=/inventory \
  --mount type=bind,source="$(pwd)"/.terraform/modules/kubernetes/kubernetes/generate_inventory.py,dst=/kubespray/generate_inventory.py \
  --mount type=bind,source="$(pwd)"/terraform.tfstate,dst=/kubespray/terraform.tfstate \
  --mount type=bind,source="$(pwd)"/.terraform/modules/kubernetes/kubernetes/cluster.yml,dst=/kubespray/cluster.yml \
  --mount type=bind,source="${HOME}"/.kube,dst=/root/.kube \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.24.0 bash

# Inside a container
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_rsa
ansible-playbook -i generate_inventory.py cluster.yml
```

## (FYI) Create cluster by using static inventory
Generate hosts.yaml file:
```
$ .terraform/modules/kubernetes/kubernetes/generate_inventory.py | .terraform/modules/kubernetes/kubernetes/convert_inventory_to_yaml.sh > ./inventory/hosts.yaml
```

Create a Kubernetes cluster:
```
$ docker run --rm -it \
  --mount type=bind,source="$(pwd)"/inventory,dst=/inventory \
  --mount type=bind,source="$(pwd)"/cluster.yml,dst=/kubespray/cluster.yml \
  --mount type=bind,source="${HOME}"/.kube,dst=/root/.kube \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.24.0 bash

# Inside a container
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_rsa
ansible-playbook -i /inventory/hosts.yaml cluster.yml
```
