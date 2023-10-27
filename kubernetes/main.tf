#******** Variable definitions ********#
variable "libvirt_uri" {}
variable "vm_base_image_uri" {}
variable "virtual_bridge" {}
variable "gateway" {}
variable "nameservers" {}
variable "vms" {
  type = list(
    object({
      name        = string
      vcpu        = number
      memory      = number
      disk        = number
      ip          = string
      mac         = string
      description = string
    })
  )
}

#******** Providers ********#
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.4"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

#******** cloudinit ********#
data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config" {
  count    = length(var.vms)
  template = file("${path.module}/network_config.cfg.tpl")
  vars = {
    ip          = var.vms[count.index].ip
    gateway     = var.gateway
    nameservers = var.nameservers
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count          = length(var.vms)
  name           = "commoninit_${var.vms[count.index].name}.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config[count.index].rendered
}

#******** VMs ********#
resource "libvirt_domain" "vm" {
  count       = length(var.vms)
  description = var.vms[count.index].description

  name   = var.vms[count.index].name
  vcpu   = var.vms[count.index].vcpu
  memory = var.vms[count.index].memory

  disk {
    volume_id = libvirt_volume.vm_volume[count.index].id
  }
  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id
  autostart = true

  network_interface {
    hostname  = var.vms[count.index].name
    addresses = [var.vms[count.index].ip]
    mac       = var.vms[count.index].mac
    bridge    = var.virtual_bridge
  }
  qemu_agent = true

  cpu {
    mode = "host-passthrough"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}

resource "libvirt_volume" "vm_volume" {
  count          = length(var.vms)
  name           = "${var.vms[count.index].name}.qcow2"
  pool           = "default"
  format         = "qcow2"
  base_volume_id = var.vm_base_image_uri
  size           = var.vms[count.index].disk
}
