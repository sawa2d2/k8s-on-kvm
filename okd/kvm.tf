##******** Network settings ********#
#resource "libvirt_network" "openshift_network" {
#  name   = "openshift_net"
#  mode   = "nat"
#  domain = "openshift.local"
#  addresses = ["10.11.12.1/24"]
#  #routes {
#  #  cidr = "10.17.0.0/16"
#  #  gateway = "10.18.0.2"
#  #}
#}

resource "libvirt_network" "openshift_bridge" {
  name   = "openshift_bridge"
  mode   = "bridge"
  bridge = "virbr0"
  #addresses = ["10.11.12.2/24"]
}

#******** Bootstrap ********#
resource "libvirt_domain" "coreos_bootstrap" {
  name   = "coreos_bootstrap"
  memory = 8000 #16000 # [MiB]
  vcpu   = 4 
  
  disk {
    volume_id = libvirt_volume.coreos_bootstrap_volume.id
  }

#  network_interface {
#    hostname = "bootstrap"
#    network_id = libvirt_network.openshift_bridge.id
#    addresses      = ["10.11.12.49"]
#    mac            = "AA:BB:CC:11:22:22"
#  }

  network_interface {
    network_id = libvirt_network.openshift_bridge.id
    macvtap = "veth0"
    mac = "52:54:00:11:22:49"
    #bridge = "virbr0"
    addresses      = ["10.11.12.49"]
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
  memory = 8000 #16000 # [MiB]
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
    network_id = libvirt_network.openshift_bridge.id
    hostname = "master_${count.index + 1}"
  }

  network_interface {
    network_name = libvirt_network.openshift_bridge.name
    bridge = "virbr0"
    macvtap = "veth0"
    addresses      = ["10.11.12.6${count.index + 1}"]
    mac = "52:54:00:11:22:7${count.index + 1}"
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
    network_id = libvirt_network.openshift_bridge.id
    hostname = "worker_${count.index + 1}"
    addresses      = ["10.11.12.7${count.index + 1}"]
    mac = "52:54:00:11:22:7${count.index + 1}"
  }

  network_interface {
    bridge = "virbr0"
    macvtap = "veth0"
    network_id = libvirt_network.openshift_bridge.id
  }

  #network_interface {
  #  network_id = libvirt_network.openshift_bridge.id
  #}
}

resource "libvirt_volume" "coreos_compute_volume" {
  count  = 2  
  name   = "coreos_compute_${count.index + 1}.qcow2"
  format = "qcow2"
  size   = 107374182400  # [byte] = 100[GiB] (100 * 1024^3)
}
