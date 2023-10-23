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
    master_name_set = [host['name'] for host in hosts if "k8s_master" in host['name']]
    worker_name_set = [host['name'] for host in hosts if "k8s_worker" in host['name']]

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


def debug():
    tfstate = load_tfstate()
    for resource in tfstate['resources']:
        if (
            resource['type'] == 'template_file'
            and resource['name'] == "network_config_master"
        ):
            print("attributes.rendered")
            for instance in resource['instances']:
                yml = yaml.load(instance['attributes']['rendered'], Loader=yaml.SafeLoader)
                print(yml)

        if (
            resource['type'] == 'libvirt_cloudinit_disk'
            and resource['name'] == "commoninit_master"
        ):
            print("attributes.network_config")
            for instance in resource['instances']:
                yml = yaml.load(instance['attributes']['network_config'], Loader=yaml.SafeLoader)
                print(yml)


def load_tfstate():
    tfstate_path = './terraform.tfstate'
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
    tfstate = load_tfstate()

    worker_ips = extract_ips(tfstate, "network_config_worker")
    master_ips = extract_ips(tfstate, "network_config_master")
    hosts = []
    hosts.extend([{"name": f"k8s_master_{i+1}", "ip": ip} for i, ip in enumerate(master_ips)])
    hosts.extend([{"name": f"k8s_worker_{i+1}", "ip": ip} for i, ip in enumerate(worker_ips)])
    return hosts


#debug()
main()
