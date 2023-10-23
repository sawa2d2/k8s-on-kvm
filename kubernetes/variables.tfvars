# Localhost: qemu:///system
# Remote   : qemu+ssh://<user>@<host>/system
libvirt_url = "qemu:///system"

### Base image URI for VM ###
# Download the image by:
#   sudo curl -L -o /var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2 https://download.rockylinux.org/pub/rocky/9.2/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2 
vm_base_image_uri = "/var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2"

# Networking
virtual_bridge = "br0"
#cidr      = "192.168.8.0/24"
#router_ip = "192.168.8.1"

vms = [
    {
      name   = "k8s_master_1"
      vcpu   = 4
      memory = 16000 # in MiB
      disk   = 100 * 1024 * 1024 * 1024  # 100 GB
      ip     = "192.168.8.201"
      mac  = "52:54:00:00:00:01"
    },
    {
      name   = "k8s_master_2"
      vcpu   = 4
      memory = 16000 # in MiB
      disk   = 100 * 1024 * 1024 * 1024  # 100 GB
      ip     = "192.168.8.202"
      mac  = "52:54:00:00:00:02"
    },
    {
      name   = "k8s_worker_1"
      vcpu   = 2
      memory = 8000 # in MiB
      disk   = 100 * 1024 * 1024 * 1024  # 100 GB
      ip     = "192.168.8.203"
      mac  = "52:54:00:00:00:03"
    },
    {
      name   = "k8s_worker_2"
      vcpu   = 2
      memory = 8000 # in MiB
      disk   = 100 * 1024 * 1024 * 1024  # 100 GB
      ip     = "192.168.8.204"
      mac  = "52:54:00:00:00:04"
    },
]