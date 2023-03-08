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


variable coreos_image_uri {
    #source: "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230205.3.0/x86_64/fedora-coreos-37.20230205.3.0-qemu.x86_64.qcow2.xz"
    default = "/var/lib/libvirt/images/fedora-coreos-37.20230205.3.0-qemu.x86_64.qcow2"
}

resource "libvirt_ignition" "ignition" {
  name = "ignition.ign"
  content = "${path.module}/ignition.ign"
}

resource "libvirt_domain" "coreos" {
  name = "coreos"
  memory = 4000  # in MiB
  vcpu = 2
  disk {
    volume_id = libvirt_volume.coreos_volume.id
  }
  coreos_ignition = libvirt_ignition.ignition.id

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }
}

resource "libvirt_volume" "coreos_volume" {
  name = "coreos.qcow2"
  pool = "default" 
  format = "qcow2"
  base_volume_id = var.coreos_image_uri
  size   = 20 * 1024 * 1024 * 1024  # 20 GB
}