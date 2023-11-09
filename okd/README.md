# How to create an OKD4 cluster on KVM with Terraform

Here is a sample code of this article (TBD).

## Summary

This docs will explain how to deploy an OKD4 cluster on KVM using Terraform according to the steps:

1. Create `install-config.yaml`for OKD4 settings
1. Generate ignition files by `openshift-install` command
1. Create KVMs by terraform with the ignition files

The figure below represent the installation flow:

![Network architecture](./images/installation-flow.png)

The network configuration in this repository is as shown in the diagram below:

![Network architecture](./images/network_architecture.drawio.png)

## Prerequisites
- `terraform`
- `podman`
- KVM Packages
  - `qemu-kvm`
  - `libvirt`

## Prepare HAProxy
Create the folowing network config file `tt0.conflist` in `/etc/cni/net.d`:

```
{
  "cniVersion": "0.4.0",
  "name": "tt0",
  "plugins": [
    {
      "type": "bridge",
      "bridge": "tt0",
      "isGateway": true,
      "ipMasq": true,
      "ipam": {
        "type": "static",
        "addresses": [
          {
            "address": "192.168.126.5/24",
            "gateway": "192.168.126.1"
          }
        ]
      }
    },
    {
      "type": "portmap",
      "capabilities": {
        "portMappings": true
      }
    }
  ]
}
```

## Preparing ignition files

Install openshift-install command:

```
$ curl -LO https://github.com/okd-project/okd/releases/download/3.14.0-0.okd-2023-10-28-073550/openshift-install-linux-4.14.0-0.okd-2023-10-28-073550.tar.gz
$ tar -zxvf openshift-install-linux-4.14.0-0.okd-2023-10-28-073550.tar.gz
$ mv openshift-install /usr/local/bin
$ openshift-install version
openshift-install 4.14.0-0.okd-2023-10-28-073550
built from commit 03546e550ae68f6b36d78d78b539450e66b5f6c2
release image quay.io/openshift/okd@sha256:7a6200e347a1b857e47f2ab0735eb1303af7d796a847d79ef9706f217cd12f5c
release architecture amd64
```

Create `install-config.yaml` as below:

```
apiVersion: v1
baseDomain: example.com
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
metadata:
  name: ocp4
networking:
  clusterNetwork:
  - cidr: 192.168.126.0/24
    hostPrefix: 64
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
pullSecret: ''
sshKey: '<SSH_KEY>'
```


Generate ignition files by running `generate_ign.sh`(It will inject specific DNS configuration for UPI to ignition files. See for more details: [Manual DNS Configuration and FCOS DNS Fix · okd-project/okd](https://github.com/okd-project/okd/blob/968dbbeec8e089bddad887cff6d85a39d2c60ab1/Guides/UPI/baremetal/manual-dns-and-fcos-dns-fix.md#apply-manual-dns-configuration-fixes).):

```
$ ./generate_ign.sh
```

## Provisioning resources
Create VMs by terraform:
```
$ terraform init
$ terraform apply -auto-approve
```

Enable to refer the DNS on `tt0` (`192.168.126.1`) from your host:
```
# On host
$ sudo resolvectl dns tt0 192.168.126.1
$ sudo resolvectl domain tt0 ~ocp4.example.com
```

Build and run a HAProxy container:

```
sudo podman build -t okd-haproxy -f ./haproxy.Dockerfile
sudo podman run -it --rm --network=tt0 -p 8080:1936 -v `pwd`/haproxy.cfg:/etc/haproxy/haproxy.cfg:ro okd-haproxy /bin/bash
```
Inside a container:
```
/start-haproxy
```

You can see status of HAProxy via http://localhost:8080 and login by `admin:test`.

((((OR)))):

```
sudo podman run -it --network=tt0 -v `pwd`/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro --sysctl net.ipv4.ip_unprivileged_port_start=0 haproxy bash
```

Inside a container:
```
haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg
```

Now 6VMs and one container are run on the bridge `tt0`:
```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
tt0             8000.525400b3d152       yes             veth26fc05a2
                                                        vnet0
                                                        vnet1
                                                        vnet2
                                                        vnet3
                                                        vnet4
                                                        vnet5
```

## Waiting for an OKD cluster is build
See the progress of installation:
```
openshift-install wait-for bootstrap-complete --log-level=info
```

For more details, execute the following in the bootstrap node:
```
journalctl -u bootkube | grep bootkube.sh | tail -n 20
```

## Cleanup

Delete the bridge `tt0`:
```
brctl show
sudo brctl delbr tt0
```

Delete files `openshift-instasll` generated:
```
rm -rf  bootstrap.ign bootstrap_injection.ign master.ign worker.ign .openshift_install.log .openshift_install_state.json auth/
```
