#!/bin/bash

cat |
yq -P eval '
. * ._meta | del(._meta) |
.hosts = .hostvars | del(.hostvars) |
.children.kube_control_plane.hosts = .kube_control_plane |
.children.kube_node.hosts = .kube_node |
.children.etcd.hosts = .etcd  |
.children.k8s_cluster = .k8s_cluster |
del(.kube_control_plane, .kube_node, .etcd, .k8s_cluster, .calico_rr) |
.all.hosts = .hosts |
.all.children = .children |
del(.hosts, .children)' |
sed 's/\(.*\)- \(.*\)/\1\2:/g'

