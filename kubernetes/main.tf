locals {
  cluster_cidr_splitted      = split("/", var.cidr)
  cluster_cidr_subnet        = local.cluster_cidr_splitted[0]
  cluster_cidr_prefix        = local.cluster_cidr_splitted[1]
  cluster_nameservers_string = "[\"${join("\", \"", var.nameservers)}\"]"

  # Auto-calculate mac address from IP 
  cluster_ips_parts = [for vm in var.vms : split(".", vm.public_ip)]
  cluster_mac_addrs = [
    for ip_parts in local.cluster_ips_parts : format(
      "52:54:00:%02X:%02X:%02X",
      tonumber(ip_parts[1]),
      tonumber(ip_parts[2]),
      tonumber(ip_parts[3])
    )
  ]
  private_ips_parts = [for vm in var.vms : split(".", vm.private_ip)]
  private_mac_addrs = [
    for ip_parts in local.private_ips_parts : format(
      "52:54:00:%02X:%02X:%02X",
      tonumber(ip_parts[1]),
      tonumber(ip_parts[2]),
      tonumber(ip_parts[3])
    )
  ]
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = length(var.vms)
  name  = "commoninit_${var.vms[count.index].name}.iso"
  user_data = template_file(var.vms[count.index].cloudinit_file, {
    hostname = var.vms[count.index].name
  })
  network_config = template_file("${path.module}/network_config.cfg", {
    ip          = var.vms[count.index].public_ip
    cidr_prefix = local.cluster_cidr_prefix
    gateway     = var.gateway
    nameservers = local.cluster_nameservers_string
  })
  pool = var.pool
}

locals {
  volume_list      = { for vm in var.vms : "${vm.name}" => flatten([for volume in vm.volumes : volume]) }
  volume_name_list = [for vm, volumes in local.volume_list : [for volume in volumes : { "name" : "${vm}_${volume.name}", "disk" : volume.disk }]]
  volumes          = flatten(local.volume_name_list)
  volumes_indexed  = { for index, volume in local.volumes : volume.name => index }
}

resource "libvirt_domain" "vm" {
  count  = length(var.vms)
  name   = var.vms[count.index].name
  vcpu   = var.vms[count.index].vcpu
  memory = var.vms[count.index].memory

  disk {
    volume_id = libvirt_volume.system[count.index].id
  }

  dynamic "disk" {
    for_each = local.volume_list[var.vms[count.index].name]
    content {
      volume_id = libvirt_volume.volume[lookup(local.volumes_indexed, "${var.vms[count.index].name}_${disk.value.name}")].id
    }
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id
  autostart = true

  # Public network
  network_interface {
    bridge    = var.bridge
    addresses = [var.vms[count.index].public_ip]
    mac       = local.cluster_mac_addrs[count.index]
  }

  # Private network
  network_interface {
    network_name = "default"
    addresses    = [var.vms[count.index].private_ip]
    mac          = local.private_mac_addrs[count.index]
  }

  qemu_agent = true

  cpu {
    mode = "host-passthrough"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  # Makes the tty0 available via `virsh console`
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

resource "libvirt_volume" "system" {
  count          = length(var.vms)
  name           = "${var.vms[count.index].name}_system.qcow2"
  pool           = var.pool
  format         = "qcow2"
  base_volume_id = var.vm_base_image_uri
  size           = var.vms[count.index].disk
}

resource "libvirt_volume" "volume" {
  count  = length(local.volumes)
  name   = "${local.volumes[count.index].name}.qcow2"
  pool   = var.pool
  format = "qcow2"
  size   = local.volumes[count.index].disk
}
