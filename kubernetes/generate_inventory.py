#!/usr/bin/env python3

import json
import subprocess


def main():
    hosts = get_hosts()

    hostvars = {}
    kube_control_plane = []
    kube_node = []
    etcd = []

    for host in hosts:
        name = host['name']
        ip = host['ip']
        hostvars.update({
          name: {
              "ansible_host": ip,
              "ip": ip,
              "access_ip": ip,
          }
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
        },
        "calico_rr": {
            "hosts": {}
        }
    }

    print(json.dumps(inventory))


def get_hosts():
    cmd = ['terraform', 'output', '-json']
    res = subprocess.run(cmd, stdout=subprocess.PIPE, text=True)
    res_json = json.loads(res.stdout)
    return res_json['kubespray_hosts']['value']


main()
