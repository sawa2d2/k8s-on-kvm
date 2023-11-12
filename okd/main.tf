module "network" {
  source = "github.com/sawa2d2/terraform-modules//libvirt-nat/"

  libvirt_uri  = var.libvirt_uri
  network_name = var.network_name
  domain       = var.domain
  bridge_name  = var.bridge_name
  cidr         = var.cidr
  nameservers  = var.nameservers

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
    [
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
        option_value = "/*.apps.${var.domain}/${var.load_balancer_ip}"
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

module "bootstrap" {
  source = "github.com/sawa2d2/terraform-modules//libvirt-ignition-nat/"

  libvirt_uri       = var.libvirt_uri
  vm_base_image_uri = var.vm_base_image_uri
  network_name      = var.network_name
  vms               = [var.bootstrap]
}

module "cluster" {
  source = "github.com/sawa2d2/terraform-modules//libvirt-ignition-nat/"

  libvirt_uri       = var.libvirt_uri
  vm_base_image_uri = var.vm_base_image_uri
  network_name      = var.network_name
  vms               = concat(var.masters, var.workers)
}