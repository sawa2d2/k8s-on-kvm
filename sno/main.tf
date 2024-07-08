terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_domain" "vm" {
  name   = "master0"
  vcpu   = 16
  memory = 32768

  boot_device {
    dev = ["hd", "cdrom"]
  }

  disk {
    file = "/var/lib/libvirt/images/agent.x86_64.iso"
  }

  disk {
    volume_id = libvirt_volume.volume.id
  }

  autostart = true

  network_interface {
    bridge    = "br0"
    addresses = ["192.168.8.80"]
    mac       = "52:54:00:00:00:50"
  }

  cpu {
    mode = "host-passthrough"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}

resource "libvirt_volume" "volume" {
  name   = "sno.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = 500 * 1024 * 1024 * 1024
}

