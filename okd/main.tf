locals {
  dns_hosts = var.use_dns_instead_of_haproxy ? concat(
    [
      for vm in var.masters : {
        hostname = "api.${var.domain}"
        ip       = vm.ip
      }
    ],
    [
      for vm in var.masters : {
        "hostname" : "api-int.${var.domain}"
        "ip" : vm.ip
      }
    ],
    var.exclude_bootstrap ? [] : [
      {
        hostname = "api.${var.domain}"
        ip       = var.bootstrap.ip
      },
      {
        hostname = "api-int.${var.domain}"
        ip       = var.bootstrap.ip
      },
    ],
  ) : []

  dnsmasq_options = concat(
    var.use_dns_instead_of_haproxy ? [] : [
      {
        option_name  = "address"
        option_value = "/api.${var.domain}/${var.load_balancer_ip}"
      },
      {
        option_name  = "address"
        option_value = "/api-int.${var.domain}/${var.load_balancer_ip}"
      },
      {
        option_name  = "address"
        option_value = "/apps.${var.domain}/${var.load_balancer_ip}"
      },
    ],
    var.exclude_bootstrap ? [] : [
      {
        option_name  = "address"
        option_value = "/bootstrap.${var.domain}/${var.bootstrap.ip}"
      },
    ],
    [
      for vm in var.masters : {
        option_name  = "address",
        option_value = "/${vm.name}.${var.domain}/${vm.ip}"
      }
    ],
    [
      for vm in var.workers : {
        option_name  = "address"
        option_value = "/${vm.name}.${var.domain}/${vm.ip}"
      }
    ],
  )
}

resource "libvirt_network" "network" {
  name      = var.network_name
  mode      = "nat"
  domain    = var.domain
  bridge    = var.bridge_name
  addresses = [var.cidr]
  autostart = true

  dns {
    local_only = true
    dynamic "hosts" {
      for_each = local.dns_hosts
      content {
        hostname = hosts.value.hostname
        ip       = hosts.value.ip
      }
    }
  }

  dnsmasq_options {
    dynamic "options" {
      for_each = local.dnsmasq_options
      content {
        option_name  = options.value["option_name"]
        option_value = options.value["option_value"]
      }
    }
  }
}

module "bootstrap" {
  source = "github.com/sawa2d2/terraform-modules//libvirt-ignition-nat/"

  libvirt_uri       = var.libvirt_uri
  pool              = var.pool
  vm_base_image_uri = var.vm_base_image_uri
  network_name      = var.network_name
  vms               = [var.bootstrap]
}

module "cluster" {
  source = "github.com/sawa2d2/terraform-modules//libvirt-ignition-nat/"

  libvirt_uri       = var.libvirt_uri
  pool              = var.pool
  vm_base_image_uri = var.vm_base_image_uri
  network_name      = var.network_name
  vms               = concat(var.masters, var.workers)
}
