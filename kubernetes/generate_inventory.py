#!/usr/bin/env python3

import json
import yaml
import re

def main():
    inventory = {
        "_meta": {
            "hostvars": {},
        },
        "etcd": [],
        "k8s_cluster": {
            "children": [
                "kube_control_plane",
                "kube_node",
            ]
        },
        "kube_control_plane": [],
        "kube_node": [],
    }
    # Set .all.hosts
    hosts = get_hosts()
    for host in hosts:
        inventory['_meta']['hostvars'][host['name']] = {
            "ansible_host": host['ip'],
            "ip": host['ip'],
            "access_ip": host['ip'],
        }

    # Set .all.children
    master_name_set = [host['name'] for host in hosts if "k8s.master" in host['name']]
    worker_name_set = [host['name'] for host in hosts if "k8s.worker" in host['name']]

    control_plane = master_name_set
    inventory['kube_node'] = control_plane

    kube_node = []
    kube_node.extend(master_name_set)
    kube_node.extend(worker_name_set)
    inventory['kube_control_plane'] = kube_node

    etcd = []
    etcd.extend(master_name_set)
    if len(master_name_set) % 2 == 0:
        etcd.append(worker_name_set[0])
    inventory['etcd'] = etcd

    print(json.dumps(inventory))


def load_tfstate(tfstate_path):
    with open(tfstate_path) as f:
        return json.load(f)


def extract_ips(tfstate, resource_name):
    ips = []
    for resource in tfstate['resources']:
        if (
            resource['type'] == 'template_file'
            and resource['name'] == resource_name
        ):
            for instance in resource['instances']:
                yml = yaml.load(instance['attributes']['rendered'], Loader=yaml.SafeLoader)
                ip_addr = yml['ethernets']['eth0']['addresses'][0].split('/')[0]
                ips.append(ip_addr)
    return ips


def get_hosts():
    # Load .tfstate
    tfstate_path = './terraform.tfstate'
    tfstate = load_tfstate(tfstate_path)

    worker_ips = extract_ips(tfstate, "network_config_worker")
    master_ips = extract_ips(tfstate, "network_config_master")
    hosts = []
    hosts.extend([{"name": f"k8s.master{i+1}", "ip": ip} for i, ip in enumerate(master_ips)])
    hosts.extend([{"name": f"k8s.worker{i+1}", "ip": ip} for i, ip in enumerate(worker_ips)])
    return hosts


main()
