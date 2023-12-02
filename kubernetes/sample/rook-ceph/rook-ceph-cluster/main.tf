output "kubespray_hosts" {
  value = module.kubernetes.kubespray_hosts
}

output "libvirt_uri" {
    value = module.kubernetes.libvirt_uri
}

locals {
    user_home_directory = pathexpand("~")
}

module "kubernetes" {
  source = "github.com/sawa2d2/k8s-on-kvm//kubernetes/"

  # Localhost: "qemu:///system"
  # Remote   : "qemu+ssh://<user>@<host>/system"
  #libvirt_uri = "qemu:///system"
  #libvirt_uri = "qemu+ssh://root@str.lan/system"
  libvirt_uri = "qemu+ssh://root@str.lan/system?keyfile=${local.user_home_directory}/.ssh/id_rsa&known_hosts_verify=ignore"


  # Download the image by:
  #   sudo curl -L -o /var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2 https://download.rockylinux.org/pub/rocky/9.2/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2 
  vm_base_image_uri = "/home/images/Rocky-9-GenericCloud.latest.x86_64.qcow2"
  pool              = "home"

  # Public network
  bridge      = "br0"
  cidr        = "192.168.8.0/24"
  gateway     = "192.168.8.1"
  nameservers = ["192.168.8.1"]

  vms = [
    {
      name           = "storage1"
      vcpu           = 2
      memory         = 4196                     # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      public_ip      = "192.168.8.201"
      private_ip     = "192.168.122.201"
      cloudinit_file = "cloud_init.cfg"
      volumes = [
        {
          name = "vdb"
          disk = 512 * 1024 * 1024 * 1024 # 500 GB
        },
        {
          name = "vdc"
          disk = 512 * 1024 * 1024 * 1024 # 500 GB
        },
      ]

      kube_control_plane = true
      kube_node          = true
      etcd               = true
    },
    {
      name           = "storage2"
      vcpu           = 1
      memory         = 4096                     # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      public_ip      = "192.168.8.202"
      private_ip     = "192.168.122.202"
      cloudinit_file = "cloud_init.cfg"
      volumes = [
        {
          name = "vdb"
          disk = 1024 * 1024 * 1024 * 1024 # 1 TB 
        },
      ]

      kube_control_plane = false
      kube_node          = true
      etcd               = false
    },
    {
      name           = "storage3"
      vcpu           = 1
      memory         = 4096                     # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      public_ip      = "192.168.8.203"
      private_ip     = "192.168.122.203"
      cloudinit_file = "cloud_init.cfg"
      volumes = [
        {
          name = "vdb"
          disk = 1024 * 1024 * 1024 * 1024 # 1 TB 
        },
      ]

      kube_control_plane = false
      kube_node          = true
      etcd               = false
    },
  ]
}

