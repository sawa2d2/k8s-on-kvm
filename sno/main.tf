terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.1"
    }
  }
}

provider "libvirt" {
  # Localhost:
  #   uri = "qemu:///system"
  # Remote:
  #   uri = "qemu+ssh://<user>@<remote-host>/system?keyfile=${pathexpand("~")}/.ssh/id_rsa&known_hosts_verify=ignore"
  # Remote via bastion:
  #   Forward port in advance:
  #     $ ssh -C -N -f -L 50000:<remote-user>@<remote-host>:22 <bastion-host> -p <bastion-port>
  #   uri = "qemu+ssh://<remote-user>@localhost:50000/system?keyfile=${pathexpand("~")}/.ssh/id_rsa&known_hosts_verify=ignore"
  uri = "qemu:///system"
}

resource "libvirt_domain" "vm" {
  name    = "master0"
  vcpu    = 16
  memory  = 65536
  machine = "q35"

  boot_device {
    dev = ["hd", "cdrom"]
  }

  disk {
    file = "/var/lib/libvirt/images/agent.x86_64.iso"
  }

  disk {
    volume_id = libvirt_volume.system.id
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

  xml {
    xslt = file("${path.module}/patch.xsl")
  }
}

resource "libvirt_volume" "system" {
  name   = "sno_system.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = 512 * 1024 * 1024 * 1024
}

resource "libvirt_volume" "volume" {
  name   = "sno_volume.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = 1024 * 1024 * 1024 * 1024
}

