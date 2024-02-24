terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

locals {
  install_config_file = file("install-config.backup.yaml")
  install_config      = yamldecode(local.install_config_file)
  domain              = "${local.install_config["metadata"]["name"]}.${local.install_config["baseDomain"]}"

  agent_config_file = file("agent-config.backup.yaml")
  agent_config      = yamldecode(local.agent_config_file)
  vms               = local.agent_config["hosts"]
}

resource "libvirt_domain" "vm" {
  count  = length(local.vms)
  name   = local.vms[count.index].hostname
  vcpu   = 8
  memory = 16384

  boot_device {
    dev = ["cdrom", "hd"]
  }

  disk {
    file = "/home/images/agent.x86_64.iso"
  }

  disk {
    volume_id = libvirt_volume.volume.id
    scsi      = "true"
  }

  autostart = true

  network_interface {
    bridge    = var.bridge
    addresses = [local.vms[count.index].networkConfig.interfaces[0].ipv4.address[0].ip]
    mac       = local.vms[count.index].interfaces[0].macAddress
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
  #count  = length(local.volumes)
  name   = "sno.qcow2"
  pool   = var.pool
  format = "qcow2"
  #size   = local.volumes[count.index].disk
  size = 1000 * 1024 * 1024 * 1024
}

