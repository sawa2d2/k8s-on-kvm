module "kubernetes" {
  source = "github.com/sawa2d2/k8s-on-kvm//kubernetes/"

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
      name           = "storage1"
      vcpu           = 4
      memory         = 16384                    # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      ip             = "192.168.8.201"
      mac            = "52:54:00:00:02:01"
      cloudinit_file = "${path.module}/cloud_init.cfg"
      description    = ""
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
      vcpu           = 2
      memory         = 16384                    # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      ip             = "192.168.8.202"
      mac            = "52:54:00:00:02:02"
      cloudinit_file = "cloud_init.cfg"
      description    = ""
      volumes = [
        {
          name = "vdb"
          disk = 1024 * 1024 * 1024 * 1024 # 1 TB 
        },
      ]

      kube_control_plane = false
      kube_node          = true
      etcd               = true
    },
    {
      name           = "storage3"
      vcpu           = 2
      memory         = 16384                    # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      ip             = "192.168.8.203"
      mac            = "52:54:00:00:02:03"
      cloudinit_file = "cloud_init.cfg"
      description    = ""
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
      name           = "app"
      vcpu           = 4
      memory         = 16284                    # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      ip             = "192.168.8.204"
      mac            = "52:54:00:00:02:04"
      cloudinit_file = "cloud_init.cfg"
      description    = ""
      volumes        = []

      kube_control_plane = true
      kube_node          = true
      etcd               = true
    },
  ]
}

output "kubespray_hosts" {
  value = module.kubernetes.kubespray_hosts
}
