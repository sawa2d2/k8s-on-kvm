##******** Network settings ********#
resource "libvirt_network" "okd_network" {
  name = "okd_network"
  mode = "nat"
  addresses = ["192.168.1.1/24"]
  routes {
      cidr = "192.168.1.0/24"
      gateway = "192.168.1.1"
    }
  dhcp {
    enabled = false
  }
}

#******** Ignition settings *******#
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
  autostart = true

  network_interface {
    network_name = "default"
  }

  network_interface {
    network_id = libvirt_network.okd_network.id
    hostname   = "bootstrap"
    addresses  = ["192.168.1.200"]
    macvtap = "enp2s0"
    wait_for_lease = true
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
  autostart = true

  network_interface {
    network_id = libvirt_network.okd_network.id
    hostname   = "master_${count.index + 1}"
    addresses  = ["192.168.1.${200 + count.index + 1}"]
    macvtap = "enp2s0"
    wait_for_lease = true
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
  autostart = true

  network_interface {
    network_id = libvirt_network.okd_network.id
    hostname   = "worker_${count.index + 1}"
    addresses  = ["192.168.1.${200 + count.index + 4}"]
    macvtap = "enp2s0"
    wait_for_lease = true
  }
}

resource "libvirt_volume" "coreos_compute_volume" {
  count  = var.worker.count
  name   = "coreos_compute_${count.index + 1}.qcow2"
  format = "qcow2"
  base_volume_id = var.coreos_image_uri
  size   = var.worker.disk
}
