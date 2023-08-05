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
  name = "k8snet"
  mode = "bridge"
  bridge = "br0"
  autostart = true
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

#******** Master nodes ********#
data "template_file" "network_config_master" {
  count  = var.master.count
  template = file("${path.module}/network_config_k8s_master_${count.index + 1}.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit_master" {
  count  = var.master.count
  name           = "commoninit_master_${count.index + 1}.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config_master[count.index].rendered
}

resource "libvirt_domain" "k8s_master" {
  count  = var.master.count
  name   = "k8s_master_${count.index + 1}"
  memory = var.master.memory
  vcpu   = var.master.vcpu

  disk {
    volume_id = libvirt_volume.k8s_master_volume[count.index].id
  }
  cloudinit = libvirt_cloudinit_disk.commoninit_master[count.index].id
  autostart = true

  network_interface {
    network_id = libvirt_network.k8s_network.id
    hostname   = "master_${count.index + 1}"
    addresses  = ["192.168.1.${200 + count.index + 1}"]
    mac  = "52:54:00:00:00:0${count.index + 1}"
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
data "template_file" "network_config_worker" {
  count  = var.worker.count
  template = file("${path.module}/network_config_k8s_worker_${count.index + 1}.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit_worker" {
  count  = var.worker.count
  name           = "commoninit_worker_${count.index + 1}.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config_worker[count.index].rendered
}

resource "libvirt_domain" "k8s_worker" {
  count  = var.worker.count
  name   = "k8s_worker_${count.index + 1}"
  memory = var.worker.memory
  vcpu   = var.worker.vcpu

  disk {
    volume_id = libvirt_volume.k8s_worker_volume[count.index].id
  }
  cloudinit = libvirt_cloudinit_disk.commoninit_worker[count.index].id
  autostart = true

  network_interface {
    network_id = libvirt_network.k8s_network.id
    hostname   = "worker_${count.index + 1}"
    addresses  = ["192.168.1.${200 + count.index + 3}"]
    mac  = "52:54:00:00:00:0${count.index + 3}"
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
