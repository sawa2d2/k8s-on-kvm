output "kubespray_hosts" {
  value = module.kubernetes.kubespray_hosts
}

module "kubernetes" {
  source = "github.com/sawa2d2/k8s-on-kvm//kubernetes/"

  # Localhost: "qemu:///system"
  # Remote   : "qemu+ssh://<user>@<host>/system"
  libvirt_uri = "qemu:///system"

  # Download the image by:
  #   sudo curl -L -o /var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2 https://download.rockylinux.org/pub/rocky/9.2/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2 
  vm_base_image_uri = "/var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2"
  pool              = "default"

  # Public network
  bridge      = "br0"
  cidr        = "192.168.8.0/24"
  gateway     = "192.168.8.1"
  nameservers = ["192.168.8.1"]

  vms = [
    {
      name           = "app"
      vcpu           = 4
      memory         = 16384                    # in MiB
      disk           = 100 * 1024 * 1024 * 1024 # 100 GB
      public_ip      = "192.168.8.204"
      private_ip     = "192.168.122.204"
      cloudinit_file = "cloud_init.cfg"
      volumes        = []

      kube_control_plane = true
      kube_node          = true
      etcd               = true
    }
  ]
}

