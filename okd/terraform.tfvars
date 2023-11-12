libvirt_uri                = "qemu:///system"
domain                     = "ocp4.example.com"
network_name               = "okd"
bridge_name                = "tt0"
cidr                       = "192.168.126.0/24"
gateway                    = "192.168.126.1"
nameservers                = ["192.168.126.1"]
use_dns_instead_of_haproxy = true
load_balancer_ip           = "192.168.126.5"

# Download a CoreOS image from:
#   $ openshift-install version
#   openshift-install 4.14.0-0.okd-2023-10-28-073550
#   $ wget $(openshift-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.qemu.formats["qcow2.xz"].disk.location')
#   $ xz -dv *.qcow2.xz
#vm_base_image_uri = "/var/lib/libvirt/images/fedora-coreos-38.20230609.3.0-qemu.x86_64.qcow2"
vm_base_image_uri = "/var/lib/libvirt/images/fedora-coreos-38.20231002.3.1-qemu.x86_64.qcow2"

bootstrap = {
  name          = "bootstrap"
  vcpu          = 4
  memory        = 16384                    # in MiB
  disk          = 100 * 1024 * 1024 * 1024 # 100 GB
  ip            = "192.168.126.100"
  mac           = "52:54:00:00:00:00"
  ignition_file = "bootstrap.ign"
  description   = ""
  volumes       = []
}

masters = [
  {
    name          = "master0"
    vcpu          = 4
    memory        = 16284                    # in MiB
    disk          = 100 * 1024 * 1024 * 1024 # 100 GB
    ip            = "192.168.126.101"
    mac           = "52:54:00:00:00:01"
    ignition_file = "master.ign"
    description   = ""
    volumes       = []
  },
  {
    name          = "master1"
    vcpu          = 4
    memory        = 16384                    # in MiB
    disk          = 100 * 1024 * 1024 * 1024 # 100 GB
    ip            = "192.168.126.102"
    mac           = "52:54:00:00:00:02"
    ignition_file = "master.ign"
    description   = ""
    volumes       = []
  },
  {
    name          = "master2"
    vcpu          = 4
    memory        = 16384                    # in MiB
    disk          = 100 * 1024 * 1024 * 1024 # 100 GB
    ip            = "192.168.126.103"
    mac           = "52:54:00:00:00:03"
    ignition_file = "master.ign"
    description   = ""
    volumes       = []
  },
]

workers = [
  {
    name          = "worker0"
    vcpu          = 2
    memory        = 8192                     # in MiB
    disk          = 100 * 1024 * 1024 * 1024 # 100 GB
    ip            = "192.168.126.104"
    mac           = "52:54:00:00:00:04"
    ignition_file = "worker.ign"
    description   = ""
    volumes       = []
  },
  {
    name          = "worker1"
    vcpu          = 2
    memory        = 8192                     # in MiB
    disk          = 100 * 1024 * 1024 * 1024 # 100 GB
    ip            = "192.168.126.105"
    mac           = "52:54:00:00:00:05"
    ignition_file = "worker.ign"
    description   = ""
    volumes       = []
  },
]