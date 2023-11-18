variable "libvirt_uri" {
  type = string
}

variable "vm_base_image_uri" {
  type = string
}

variable "bridge" {
  type = string
}

variable "gateway" {
  type = string
}

variable "cidr" {
  type = string
}

variable "nameservers" {
  type = list(string)
}

variable "pool" {
  type    = string
  default = "default"
}

variable "vms" {
  type = list(
    object({
      name           = string
      vcpu           = number
      memory         = number
      disk           = number
      public_ip      = string
      private_ip     = string
      cloudinit_file = string
      volumes = list(
        object({
          name = string
          disk = number
        })
      )

      kube_control_plane = bool
      kube_node          = bool
      etcd               = bool
    })
  )
}
