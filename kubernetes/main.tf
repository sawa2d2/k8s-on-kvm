terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

#******** Network settings ********#
resource "libvirt_network" "k8s_network" {
  name = "k8s_network"
  mode = "nat"
  addresses = [var.k8s_network.cidr]
  routes {
      cidr = var.k8s_network.cidr
      gateway = var.k8s_network.router_ip
    }
  dhcp {
    enabled = false
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
}

#******** Master nodes ********#
resource "libvirt_domain" "k8s_master" {
  count  = var.master.count
  name   = "k8s_master_${count.index + 1}"
  memory = var.master.memory
  vcpu   = var.master.vcpu

  disk {
    volume_id = libvirt_volume.k8s_master_volume[count.index].id
  }
  cloudinit = libvirt_cloudinit_disk.commoninit.id
  autostart = true

  network_interface {
    network_id = libvirt_network.k8s_network.id
    hostname   = "master_${count.index + 1}"
    addresses  = ["192.168.1.${200 + count.index + 1}"]
    macvtap = "enp2s0"
    wait_for_lease = true
  }

  qemu_agent = true
  cpu {
    mode = "host-passthrough"
  }
}

resource "libvirt_volume" "k8s_master_volume" {
  count  = var.master.count
  name   = "k8s_master_${count.index + 1}.qcow2"
  pool = "default" 
  format = "qcow2"
  base_volume_id = var.rocky_image_uri
  size   = var.master.disk
}

#******** Worker nodes ********#
resource "libvirt_domain" "k8s_worker" {
  count  = var.worker.count
  name   = "k8s_worker_${count.index + 1}"
  memory = var.worker.memory
  vcpu   = var.worker.vcpu

  disk {
    volume_id = libvirt_volume.k8s_worker_volume[count.index].id
  }
  cloudinit = libvirt_cloudinit_disk.commoninit.id
  autostart = true

  network_interface {
    network_id = libvirt_network.k8s_network.id
    hostname   = "worker_${count.index + 1}"
    addresses  = ["192.168.1.${200 + count.index + 3}"]
    macvtap = "enp2s0"
    wait_for_lease = true
  }

  qemu_agent = true
  cpu {
    mode = "host-passthrough"
  }
}

resource "libvirt_volume" "k8s_worker_volume" {
  count  = var.worker.count
  name   = "k8s_worker_${count.index + 1}.qcow2"
  pool = "default" 
  format = "qcow2"
  base_volume_id = var.rocky_image_uri
  size   = var.worker.disk
}
