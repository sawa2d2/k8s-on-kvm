#!/usr/bin/env python3

import json
import yaml
import re


def main():
    inventory = {
        "all": {
            "hosts": {},
            "children": {
                "kube_control_plane": {
                    "hosts": {}
                },
                "kube_node": {
                    "hosts": {}
                },
                "etcd": {
                    "hosts": {}
                },
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
        }
    }
    # Set .all.hosts
    hosts = get_hosts()
    for host in hosts:
        inventory['all']['hosts'][host['name']] = {
            "ansible_host": host['ip'],
            "ip": host['ip'],
            "access_ip": host['ip'],
        }

    # Set .all.children
    master_name_set = [host['name'] for host in hosts if "k8s.master" in host['name']]
    worker_name_set = [host['name'] for host in hosts if "k8s.worker" in host['name']]

    control_plane = master_name_set
    inventory['all']['children']['kube_control_plane']['hosts'] = control_plane

    kube_node = []
    kube_node.extend(master_name_set)
    kube_node.extend(worker_name_set)
    inventory['all']['children']['kube_node']['hosts'] = kube_node

    etcd = []
    etcd.extend(master_name_set)
    if len(master_name_set) % 2 == 0:
        etcd.append(worker_name_set[0])
    inventory['all']['children']['etcd']['hosts'] = etcd

    lines = yaml.dump(inventory, sort_keys=False)
    for line in lines.splitlines():
        res = re.match("^(\s+)-\s(.+)", line)
        if res:
            print(f"  {res[1]}{res[2]}:")
        else:
            print(line)


def load_tfstate():
    tfstate_path = './terraform.tfstate'
    with open(tfstate_path) as f:
        return json.load(f)


def get_hosts():
    tfstate = load_tfstate()
    hosts = []
    for resource in tfstate['resources']:
        if resource['type'] == 'libvirt_domain' and resource['name'] == 'vm':
            for instance in resource['instances']:
                network_interface = instance['attributes']['network_interface'][0]
                hosts.append({
                    "name": network_interface['hostname'].replace('_', '.'),
                    "ip": network_interface['addresses'][0].split('/')[0],
                })
    return hosts


main()
