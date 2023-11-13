module "ceph_rook" {
  source = "github.com/sawa2d2/terraform-modules//libvirt-cloudinit-bridge/"

  libvirt_uri       = "qemu:///system"
  vm_base_image_uri = "/var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2"
  bridge            = "br0"
  gateway           = "192.168.8.1"
  nameservers       = ["192.168.8.1"]
  vms = [
    {
      name           = "storage-1"
      vcpu           = 4
      memory         = 16000                    # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      ip             = "192.168.8.201/24"
      mac            = "52:54:00:00:00:01"
      cloudinit_file = "cloud_init.cfg"
      description    = <<-EOT
      {
        "kubernetes": {
          "kube_control_plane": true,
          "kube_node": true,
          "etcd": true
        }
      }
      EOT
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
    },
    {
      name           = "storage-2"
      vcpu           = 4
      memory         = 16000                    # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      ip             = "192.168.8.202/24"
      mac            = "52:54:00:00:00:02"
      cloudinit_file = "cloud_init.cfg"
      description    = <<-EOT
      {
        "kubernetes": {
          "kube_control_plane": true,
          "kube_node": true,
          "etcd": true
        }
      }
      EOT
      volumes = [
        {
          name = "vdb"
          disk = 1024 * 1024 * 1024 * 1024 # 1 TB 
        },
      ]
    },
    {
      name           = "storage-3"
      vcpu           = 4
      memory         = 16000                    # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      ip             = "192.168.8.203/24"
      mac            = "52:54:00:00:00:03"
      cloudinit_file = "cloud_init.cfg"
      description    = <<-EOT
      {
        "kubernetes": {
          "kube_control_plane": false,
          "kube_node": true,
          "etcd": true
        }
      }
      EOT
      volumes = [
        {
          name = "vdb"
          disk = 1024 * 1024 * 1024 * 1024 # 1 TB 
        },
      ]
    },
    {
      name           = "app"
      vcpu           = 4
      memory         = 16000                    # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      ip             = "192.168.8.204/24"
      mac            = "52:54:00:00:00:04"
      cloudinit_file = "cloud_init.cfg"
      description    = <<-EOT
      {
        "kubernetes": {
          "kube_control_plane": false,
          "kube_node": true,
          "etcd": false
        }
      }
      EOT
      volumes        = []
    },
  ]
}
