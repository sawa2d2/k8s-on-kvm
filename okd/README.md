# Provisioning OKD cluster

## Provisioning

Convert by running Butane:
```
podman run -i --rm quay.io/coreos/butane:release --pretty --strict < ignition.bu > ignition.ign
```

To create a VM, run:
```
terraform init
terraform apply
```

Check the IP addresses of each node.
```
$ virsh list --all | awk '{print $2}' | tail -n +3 | xargs -i sh -c "echo {}: && virsh domifaddr {} | tail -n +3 | head -n -1"
coreos_bootstrap:
 vnet431    52:54:00:0e:3a:b1    ipv4         192.168.122.174/24
 vnet432    52:54:00:6a:d2:bd    ipv4         192.168.1.200/24
coreos_control_1:
 vnet437    52:54:00:ea:70:b6    ipv4         192.168.1.201/24
coreos_control_2:
 vnet433    52:54:00:82:71:c0    ipv4         192.168.1.202/24
coreos_compute_1:
 vnet435    52:54:00:ca:90:4a    ipv4         192.168.1.204/24
coreos_compute_2:
 vnet434    52:54:00:9e:e8:92    ipv4         192.168.1.205/24
coreos_control_3:
 vnet436    52:54:00:6a:8c:31    ipv4         192.168.1.203/24
```
