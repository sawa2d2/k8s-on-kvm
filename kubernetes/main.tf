locals {
  vm_keys = ["name", "vcpu", "memory", "disk", "ip", "mac", "cloudinit_file", "description", "volumes"]
  vms = [for vm in var.nodes :
    { for key, value in vm : key => value if contains(local.vm_keys, key) }
  ]
}

module "kubernetes" {
  source = "github.com/sawa2d2/terraform-modules//libvirt-cloudinit-bridge/"

  libvirt_uri       = var.libvirt_uri
  vm_base_image_uri = var.vm_base_image_uri

  bridge      = var.bridge
  cidr        = var.cidr
  gateway     = var.gateway
  nameservers = var.nameservers

  pool = "default"
  vms  = local.vms
}
