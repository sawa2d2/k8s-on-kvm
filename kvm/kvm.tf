terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}


#******** Provisioning settings ********#
resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  #template = file("${path.module}/cloud_init.cfg")
}


#******** Network settings ********#
# resource "libvirt_network" "coreos_network" {
#   name   = "default"
#   mode   = "nat"
#   domain = "k8s.local"
# }


#******** Bootstrap ********#
resource "libvirt_domain" "coreos_bootstrap" {
  name   = "coreos_bootstrap"
  memory = 16000 # [MiB]
  vcpu   = 4 
  
  disk {
    volume_id = libvirt_volume.coreos_bootstrap_volume.id
  }

  network_interface {
    network_name = "default"
  }
}

resource "libvirt_volume" "coreos_bootstrap_volume" {
  name   = "coreos_bootstrap.qcow2"
  format = "qcow2"
  size   = 107374182400  # [byte] = 100[GiB] (100 * 1024^3)
}

#******** Control plane ********#
resource "libvirt_domain" "coreos_control" {
  count = 3
  #for_each = to_set(var.number)

  name   = "coreos_control_${count.index + 1}"
  memory = 16000 # [MiB]
  vcpu   = 4 
  
  # TODO:
  # Enable shared memory
  #
  #memorybacking {
  #  access   = "shared"
  #  allocation = 8192
  #}

  disk {
    volume_id = libvirt_volume.coreos_control_volume[count.index].id
  }

  network_interface {
    network_name = "default"
  }
}

resource "libvirt_volume" "coreos_control_volume" {
  count  = 3  
  name   = "coreos_control_${count.index + 1}.qcow2"
  format = "qcow2"
  size   = 107374182400  # [byte] = 100[GiB] (100 * 1024^3)
}

#******** Compute plane ********#
resource "libvirt_domain" "coreos_compute" {
  count = 2 
  #for_each = to_set(var.number)

  name   = "coreos_compute_${count.index + 1}"
  memory = 8000 # [MiB]
  vcpu   = 2 

  disk {
    volume_id = libvirt_volume.coreos_compute_volume[count.index].id
  }

  network_interface {
    network_name = "default"
  }
}

resource "libvirt_volume" "coreos_compute_volume" {
  count  = 2  
  name   = "coreos_compute_${count.index + 1}.qcow2"
  format = "qcow2"
  size   = 107374182400  # [byte] = 100[GiB] (100 * 1024^3)
}