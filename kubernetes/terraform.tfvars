# Localhost: "qemu:///system"
# Remote   : "qemu+ssh://<user>@<host>/system"
libvirt_uri = "qemu:///system"

# Download the image by:
#   sudo curl -L -o /var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2 https://download.rockylinux.org/pub/rocky/9.2/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2 
vm_base_image_uri = "/var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2"
pool              = "default"

bridge      = "br0"
cidr        = "192.168.8.0/24"
gateway     = "192.168.8.1"
nameservers = ["192.168.8.1"]

nodes = [
  {
    name           = "k8s-master-1"
    vcpu           = 4
    memory         = 16000                    # in MiB
    disk           = 100 * 1024 * 1024 * 1024 # 100 GB
    ip             = "192.168.8.101"
    mac            = "52:54:00:00:01:01"
    cloudinit_file = "cloud_init.cfg"
    description    = ""
    volumes        = []

    kube_control_plane = true
    kube_node          = true
    etcd               = true
  },
  {
    name           = "k8s-master-2"
    vcpu           = 4
    memory         = 16000                    # in MiB
    disk           = 100 * 1024 * 1024 * 1024 # 100 GB
    ip             = "192.168.8.102"
    mac            = "52:54:00:00:01:02"
    cloudinit_file = "cloud_init.cfg"
    description    = ""
    volumes        = []

    kube_control_plane = true
    kube_node          = true
    etcd               = true
  },
  {
    name           = "k8s-worker-1"
    vcpu           = 2
    memory         = 8000                     # in MiB
    disk           = 100 * 1024 * 1024 * 1024 # 100 GB
    ip             = "192.168.8.103"
    mac            = "52:54:00:00:01:03"
    cloudinit_file = "cloud_init.cfg"
    description    = ""
    volumes        = []

    kube_control_plane = false
    kube_node          = true
    etcd               = true
  },
  {
    name           = "k8s-worker-2"
    vcpu           = 2
    memory         = 8000                     # in MiB
    disk           = 100 * 1024 * 1024 * 1024 # 100 GB
    ip             = "192.168.8.104"
    mac            = "52:54:00:00:01:04"
    cloudinit_file = "cloud_init.cfg"
    description    = ""
    volumes        = []

    kube_control_plane = false
    kube_node          = true
    etcd               = false
  },
]