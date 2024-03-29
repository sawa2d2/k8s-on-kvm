variable "bootstrap" {
  type = object({
    name          = string
    vcpu          = number
    memory        = number
    disk          = number
    ip            = string
    ignition_file = string
    volumes = list(
      object({
        name = string
        disk = number
      })
    )
  })
}

variable "masters" {
  type = list(
    object({
      name          = string
      vcpu          = number
      memory        = number
      disk          = number
      ip            = string
      ignition_file = string
      volumes = list(
        object({
          name = string
          disk = number
        })
      )
    })
  )
}

variable "workers" {
  type = list(
    object({
      name          = string
      vcpu          = number
      memory        = number
      disk          = number
      ip            = string
      ignition_file = string
      volumes = list(
        object({
          name = string
          disk = number
        })
      )
    })
  )
}

variable "exclude_bootstrap" {
  type    = bool
  default = false
}

variable "load_balancer_ip" {
  type    = string
  default = null
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "pool" {
  type    = string
  default = "default"
}

variable "vm_base_image_uri" {
  type = string
}

variable "network_name" {
  type    = string
  default = "okd"
}

variable "cidr" {
  type    = string
  default = "192.168.126.0/24"
}

variable "bridge_name" {
  type    = string
  default = "tt0"
}

variable "gateway" {
  type    = string
  default = "192.168.126.1"
}

variable "nameservers" {
  type    = list(string)
  default = ["192.168.126.1"]
}
