#!/usr/bin/env python3

import json


def main():
    hosts = get_hosts()

    hostvars = {}
    kube_control_plane = []
    kube_node = []
    etcd = []
    for host in hosts:
        hostvars.update({
          host['name']: {
              "ansible_host": host['ip'],
              "ip": host['ip'],
              "access_ip": host['ip'],
          }
        })
        config = host["config"]["kubernetes"]
        if config["kube_control_plane"]:
            kube_control_plane.append(host["name"])
        if config["kube_node"]:
            kube_node.append(host["name"])
        if config["etcd"]:
            etcd.append(host["name"])

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


def load_tfstate():
    tfstate_path = './terraform.tfstate'
    with open(tfstate_path) as f:
        return json.load(f)


def get_hosts():
    tfstate = load_tfstate()
    hosts = []
    for resource in tfstate['resources']:
        if resource['type'] == 'libvirt_domain':
            for instance in resource['instances']:
                attributes = instance['attributes']
                network_interface = attributes['network_interface'][0]
                hosts.append({
                    "name": network_interface['hostname'],
                    "ip": network_interface['addresses'][0].split('/')[0],
                    "config": json.loads(attributes["description"])
                })
    return hosts


main()
