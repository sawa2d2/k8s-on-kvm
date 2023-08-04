# How to create kubernetes cluster on KVM with terraform + kubespray

This is a sample code of this article [Terraform + kubespray で KVM 上に Kubernetes クラスタを構築 - Qiita](https://qiita.com/sawa2d2/items/c592dcbd958f69441068).

## Network architecture
![Network architecture](./images/network_architecture.drawio.png)

## Prerequisite
- Terraform
- podman
- KVM Packages
  - qemu-kvm
  - libvirt-clients
  - libvirt-daemon
  - bridge-utils
  - virt-manager

## Setup

Clone this repo:
```
$ git clone https://github.com/sawa2d2/k8s-on-kvm.git
$ cd k8s-on-kvm/kubernetes
```

Download a qcow2 image file of Rocky Linux 8.8 to the default pool of livbirt `/var/lib/libvirt/images/`:

```
$ sudo curl -L -o /var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2 https://download.rockylinux.org/pub/rocky/8.8/images/x86_64/Rocky-8-GenericCloud.latest.x86_64.qcow2
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
```
$ ./destroy.sh
$ ./provision.sh
```

## Creating a k8s Cluster
To create a cluster, run:
```
$ podman pull quay.io/kubespray/kubespray:v2.22.1
$ podman run --rm -it \
  --mount type=bind,source="$(pwd)"/inventory,dst=/inventory \
  --mount type=bind,source="${HOME}"/.ssh/id_ed25519,dst=/root/.ssh/id_ed25519 \
  quay.io/kubespray/kubespray:v2.22.1 bash
```

Inside the container run:
```
$ ansible-playbook -i /inventory/hosts.yaml --private-key /root/.ssh/id_ed25519 cluster.yml
```
