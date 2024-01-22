## Localhost:
# libvirt_uri = "qemu:///system"
## Remote:
# libvirt_uri = "qemu+ssh://<user>@<remote-host>/system?keyfile=${local.user_home_directory}/.ssh/id_rsa&known_hosts_verify=ignore"
## Remote via bastion:
##   Forward port in advance.
##   $ ssh -C -N -f -L 50000:<remote-user>@<remote-host>:22 <bastion-host> -p <bastion-port>
# libvirt_uri = "qemu+ssh://<remote-user>@localhost:50000/system?keyfile=${local.user_home_directory}/.ssh/id_rsa&known_hosts_verify=ignore"
libvirt_uri = "qemu:///system"

# Download the image by:
#   sudo curl -L -o /var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2 https://download.rockylinux.org/pub/rocky/9.2/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2 
vm_base_image_uri = "/var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2"
pool              = "default"

# Cluster network
bridge      = "br0"
cidr        = "192.168.8.0/24"
gateway     = "192.168.8.1"
nameservers = ["192.168.8.1"]

vms = [
  {
    name           = "k8s-master-1"
    vcpu           = 4
    memory         = 16000                    # in MiB
    disk           = 100 * 1024 * 1024 * 1024 # 100 GB
    public_ip      = "192.168.8.121"
    private_ip     = "192.168.122.201"
    cloudinit_file = "cloud_init.cfg"
    volumes        = []

    kube_control_plane = true
    kube_node          = true
    etcd               = true
  },
  {
    name           = "k8s-worker-1"
    vcpu           = 4
    memory         = 16000                    # in MiB
    disk           = 100 * 1024 * 1024 * 1024 # 100 GB
    public_ip      = "192.168.8.122"
    private_ip     = "192.168.122.202"
    cloudinit_file = "cloud_init.cfg"
    volumes        = []

    kube_control_plane = false
    kube_node          = true
    etcd               = false
  },
  {
    name           = "k8s-worker-2"
    vcpu           = 2
    memory         = 8000                     # in MiB
    disk           = 100 * 1024 * 1024 * 1024 # 100 GB
    public_ip      = "192.168.8.123"
    private_ip     = "192.168.122.203"
    cloudinit_file = "cloud_init.cfg"
    volumes        = []

    kube_control_plane = false
    kube_node          = true
    etcd               = false
  },
]
