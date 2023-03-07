##******** Network settings ********#
resource "libvirt_network" "openshift_bridge" {
  name   = "openshift_bridge"
  mode   = "bridge"
  bridge = "virbr0"
  #addresses = ["10.11.12.2/24"]
}

#******** Ignition settings ********#
resource "libvirt_ignition" "ignition_bootstrap" {
  name = "ignition_bootstrap.ign"
  content = "ignition.ign"
}

resource "libvirt_ignition" "ignition_master" {
  count = var.master.count
  name = "ignition_master_${count.index + 1}.ign"
  content = "ignition.ign"
}

resource "libvirt_ignition" "ignition_worker" {
  count = var.worker.count
  name = "ignition_worker_${count.index + 1}.ign"
  content = "ignition.ign"
}

#******** Bootstrap ********#
resource "libvirt_domain" "coreos_bootstrap" {
  name   = "coreos_bootstrap"
  vcpu   = var.bootstrap.vcpu
  memory = var.bootstrap.memory
  
  disk {
    volume_id = libvirt_volume.coreos_bootstrap_volume.id
  }
  coreos_ignition = libvirt_ignition.ignition_bootstrap.id

  network_interface {
    macvtap   = "veth0"
    mac       = "52:54:00:11:22:49"
    bridge    = "virbr0"
    addresses = ["10.11.12.49"]
  }
}

resource "libvirt_volume" "coreos_bootstrap_volume" {
  name   = "coreos_bootstrap.qcow2"
  format = "qcow2"
  base_volume_id = var.coreos_image_uri
  size   = var.bootstrap.disk
}

#******** Control plane ********#
resource "libvirt_domain" "coreos_control" {
  count  = var.master.count
  name   = "coreos_control_${count.index + 1}"
  memory = var.master.memory
  vcpu   = var.master.vcpu

  disk {
    volume_id = libvirt_volume.coreos_control_volume[count.index].id
  }
  coreos_ignition = libvirt_ignition.ignition_master[count.index].id

  network_interface {
    network_id = libvirt_network.openshift_bridge.id
    hostname   = "master_${count.index + 1}"
  }
}

resource "libvirt_volume" "coreos_control_volume" {
  count  = var.master.count
  name   = "coreos_control_${count.index + 1}.qcow2"
  format = "qcow2"
  base_volume_id = var.coreos_image_uri
  size   = var.master.disk
}

#******** Compute plane ********#
resource "libvirt_domain" "coreos_compute" {
  count = var.worker.count
  name   = "coreos_compute_${count.index + 1}"
  memory = var.worker.memory
  vcpu   = var.worker.vcpu

  disk {
    volume_id = libvirt_volume.coreos_compute_volume[count.index].id
  }
  coreos_ignition = libvirt_ignition.ignition_worker[count.index].id

  network_interface {
    network_id = libvirt_network.openshift_bridge.id
    hostname   = "worker_${count.index + 1}"
    addresses  = ["10.11.12.7${count.index + 1}"]
    mac        = "52:54:00:11:22:7${count.index + 1}"
  }
}

resource "libvirt_volume" "coreos_compute_volume" {
  count  = var.worker.count
  name   = "coreos_compute_${count.index + 1}.qcow2"
  format = "qcow2"
  base_volume_id = var.coreos_image_uri
  size   = var.worker.disk
}
