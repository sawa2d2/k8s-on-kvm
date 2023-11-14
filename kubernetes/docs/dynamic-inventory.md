# Using Dynamic Inventory of Ansible
Run a kubespray container and execute Ansible playbook:
```
$ docker pull quay.io/kubespray/kubespray:v2.23.1
$ sudo docker run --rm -it \
  --mount type=bind,source="$(pwd)"/inventory,dst=/inventory \
  --mount type=bind,source="$(pwd)"/generate_inventory.py,dst=/kubespray/generate_inventory.py \
  --mount type=bind,source="$(pwd)"/terraform.tfstate,dst=/kubespray/terraform.tfstate \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.23.1 bash

# Inside a container
$ ansible-playbook -i ./generate_inventory.py cluster.yml
```

FYI: The inventory information is extracted by `terraform output`:
```
.terraform/modules/kubernetes/kubernetes/generate_inventory.py
$ terraform output -json | jq '.kubespray_hosts.value'
```

