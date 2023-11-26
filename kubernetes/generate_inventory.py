#!/usr/bin/env python3

import json
import re


def main():
    output = get_outputs()
    hosts = output['kubespray_hosts']['value']
    libvirt_uri = output['libvirt_uri']['value']

    hostvars = {}
    kube_control_plane = []
    kube_node = []
    etcd = []

    for host in hosts:
        name = host['name']
        ip = host['ip']
        access_ip = host['access_ip']
        hostvars.update({
          name: {
              "ansible_host": access_ip,
              "ip": ip,
          }
        })
        # Check hostname
        regex = r"^qemu(\+ssh)?://([^/]*)/.*"
        res = re.match(regex, libvirt_uri)
        if res:
          hostname = res[2]
          if hostname != "":
            hostvars[name].update({
              "ansible_ssh_common_args": f"-J {hostname}"
          })

        if host["kube_control_plane"]:
            kube_control_plane.append(name)
        if host["kube_node"]:
            kube_node.append(name)
        if host["etcd"]:
            etcd.append(name)

    inventory = {
        "_meta": {
            "hostvars": hostvars,
        },
        "kube_control_plane": kube_control_plane,
        "kube_node": kube_node,
        "etcd": etcd,
        "k8s_cluster": {
            "children": [
                "kube_control_plane",
                "kube_node",
            ]
        }
    }


    print(json.dumps(inventory))


def get_outputs():
    tfstate_path = './terraform.tfstate'
    with open(tfstate_path) as f:
        tfstate = json.load(f)
    return tfstate['outputs']


main()
