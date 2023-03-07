variable coreos_image_uri {
    # The image can be downloaded from:
    #   https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230205.3.0/x86_64/fedora-coreos-37.20230205.3.0-qemu.x86_64.qcow2.xz"
    default = "/var/lib/libvirt/images/fedora-coreos-37.20230205.3.0-qemu.x86_64.qcow2"
}

variable "okd_network" {
    type = object({
        router_ip = string
        cidr      = string
    })
    default = {
        cidr      = "192.168.1.0/24"
        router_ip = "192.168.1.1"
    }
}

variable "bootstrap" {
    type = object({
        vcpu    = number
        memory  = number
        disk    = number
    })
    default = {
        vcpu    = 4
        memory  = 16000  # in MiB
        disk    = 100 * 1024 * 1024 * 1024  # 100 GB
    }
}

variable "master" {
    type = object({
        count   = number
        vcpu    = number
        memory  = number
        disk    = number
    })
    default = {
        count   = 3
        vcpu    = 4
        memory  = 16000  # in MiB
        disk    = 100 * 1024 * 1024 * 1024  # 100 GB
    }
}

variable "worker" {
    type = object({
        count   = number
        vcpu    = number
        memory  = number
        disk    = number
    })
    default = {
        count   = 2
        vcpu    = 2
        memory  = 8000  # in Mib
        disk    = 100 * 1024 * 1024 * 1024  # 100 GB 
    }
}