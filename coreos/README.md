# Provision a single CoreOS VM

## Prerequisite
- Podman

## Provision a CoreOS VM

Convert by running Butane:
```
podman run -i --rm quay.io/coreos/butane:release --pretty --strict < ignition.bu > ignition.ign
```

To create a VM, run:
```
terraform init
terraform apply -var-file *.tfvars"
```