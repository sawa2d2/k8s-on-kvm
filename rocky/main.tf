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

variable "rocky_image_uri" {
    default = "/var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2"

    # Download online:
    #default = "https://download.rockylinux.org/pub/rocky/9.1/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_domain" "rocky" {
  name   = "rocky"
  memory = 4000  # in MiB
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.rocky_volume.id
  }
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  autostart = true

  qemu_agent = true
  network_interface {
    network_name    = "default"
    wait_for_lease = true
  }

  cpu {
    mode = "host-passthrough"
  }
}

resource "libvirt_volume" "rocky_volume" {
  name = "rocky.qcow2"
  format = "qcow2"
  base_volume_id = var.rocky_image_uri
  size   = 20 * 1024 * 1024 * 1024  # 20 GB
}