locals {
  install_config_file = file("${path.module}/install-config.yaml.backup")
  install_config = yamldecode(local.install_config_file)
  domain = "${local.install_config["metadata"]["name"]}.${local.install_config["baseDomain"]}"

  dns_hosts = var.load_balancer_ip == null ? concat(
    [
      for vm in var.masters : {
        hostname = "api.${local.domain}"
        ip       = vm.ip
      }
    ],
    [
      for vm in var.masters : {
        "hostname" : "api-int.${local.domain}"
        "ip" : vm.ip
      }
    ],
    var.exclude_bootstrap ? [] : [
      {
        hostname = "api.${local.domain}"
        ip       = var.bootstrap.ip
      },
      {
        hostname = "api-int.${local.domain}"
        ip       = var.bootstrap.ip
      },
    ],
  ) : []

  dnsmasq_options = concat(
    var.load_balancer_ip != null ? [
      {
        option_name  = "address"
        option_value = "/api.${local.domain}/${var.load_balancer_ip}"
      },
      {
        option_name  = "address"
        option_value = "/api-int.${local.domain}/${var.load_balancer_ip}"
      },
      {
        option_name  = "address"
        option_value = "/apps.${local.domain}/${var.load_balancer_ip}"
      },
    ] : [],
    var.exclude_bootstrap ? [] : [
      {
        option_name  = "address"
        option_value = "/bootstrap.${local.domain}/${var.bootstrap.ip}"
      },
    ],
    [
      for vm in var.masters : {
        option_name  = "address",
        option_value = "/${vm.name}.${local.domain}/${vm.ip}"
      }
    ],
    [
      for vm in var.workers : {
        option_name  = "address"
        option_value = "/${vm.name}.${local.domain}/${vm.ip}"
      }
    ],
  )
}

resource "libvirt_network" "network" {
  name      = var.network_name
  mode      = "nat"
  domain    = local.domain
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
