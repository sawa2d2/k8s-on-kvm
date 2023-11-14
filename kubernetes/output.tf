locals {
  kubespray_hosts_keys = ["name", "ip", "kube_control_plane", "kube_node", "etcd"]
  kubespray_hosts = [for vm in var.nodes :
    { for key, value in vm : key => value if contains(local.kubespray_hosts_keys, key) }
  ]
}

output "kubespray_hosts" {
  value = local.kubespray_hosts
}