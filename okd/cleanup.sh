#1/bin/sh

# Delete bridge `tt0`
sudo nmcli con down tt0
sudo brctl delbr tt0

# Delete network `okd`
virsh net-destroy okd
virsh net-undefine okd

# Ignition files
rm -rf  bootstrap.ign bootstrap_injection.ign master.ign worker.ign .openshift_install.log .openshift_install_state.json auth/
