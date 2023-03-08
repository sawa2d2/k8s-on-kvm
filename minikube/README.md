# Provisioning a single CoreOS VM on KVM hypervisor

Edit `ignition.bu` to add your public key to `ssh_authorized_keys`
```
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - "<YOUR_SSH_KEY>"
```

Convert from the yaml `ignition.bu` to json `ignition.ign` with Butane.
```
$ podman run -i --rm quay.io/coreos/butane:release --pretty --strict < ignition.bu > ignition.ign
```

To create a VM, run:
```
$ terraform init
$ terraform apply
```

Check a VM is created:
```
$ virsh list --all
 Id    Name               State
-----------------------------------
 233   coreos             running
```

Check the VM's IP address:
```
$ virsh domifaddr coreos
 Name       MAC address          Protocol     Address
-------------------------------------------------------------------------------
 vnet250    52:54:00:c6:ae:49    ipv4         192.168.122.142/24
```

Login the VM via SSH as user `core`:
```
$ ssh core@192.168.122.142
[core@localhost ~]$ 
```

Try to start minikube:
```
[core@localhost ~]$ minikube start
😄  minikube v1.29.0 on Fedora 37 (kvm/amd64)
...
```

