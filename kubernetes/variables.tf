variable "rocky_image_uri" {
    # Download the image by:
    #   sudo curl -L -o /var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2 https://download.rockylinux.org/pub/rocky/8.8/images/x86_64/Rocky-8-GenericCloud.latest.x86_64.qcow2 
    default = "/var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2"
}

variable "k8s_network" {
    type = object({
        router_ip = string
        cidr      = string
    })
    default = {
        cidr      = "192.168.1.0/24"
        router_ip = "192.168.1.1"
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
        count   = 2 
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