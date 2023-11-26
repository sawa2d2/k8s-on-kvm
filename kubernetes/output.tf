locals {
  kubespray_hosts_keys = ["name", "kube_control_plane", "kube_node", "etcd"]
  kubespray_hosts = [for vm in var.vms :
    merge(
      {
        for key, value in vm : key => value if contains(local.kubespray_hosts_keys, key)
      },
      {
        ip        = vm.public_ip
        access_ip = vm.private_ip
    })
  ]
}

output "kubespray_hosts" {
  value = local.kubespray_hosts
}

output "libvirt_uri" {
  value = var.libvirt_uri
}
