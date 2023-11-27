# Networking
Create a network for okd:
```
terraform apply -auto-approve -target=module.okd.libvirt_network.network
```

Enable to refer libvirt's DNS from the host:
```
sudo resolvectl dns tt0 192.168.126.1
sudo resolvectl domain tt0 ~ocp4.example.com
```


Check if the network is created:
```
# Bridge:
$ bridge show
bridge name     bridge id               STP enabled     interfaces
tt0             8000.52540076c4ca       yes

# Network
$ virsh net-list
 Name      State    Autostart   Persistent
--------------------------------------------
 okd       active   yes         yes

# DNS, dnsmasq:
$ sudo cat /etc/libvirt/qemu/networks/okd.xml
<!--
WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
OVERWRITTEN AND LOST. Changes to this xml configuration should be made using:
  virsh net-edit okd
or other application using the libvirt API.
-->

<network xmlns:dnsmasq='http://libvirt.org/schemas/network/dnsmasq/1.0'>
  <name>okd</name>
  <uuid>c442bfab-8bd2-4c64-84c1-318bb9e9e423</uuid>
  <forward mode='nat'/>
  <bridge name='tt0' stp='on' delay='0'/>
  <mac address='52:54:00:76:c4:ca'/>
  <domain name='ocp4.example.com' localOnly='yes'/>
  <dns>
    <host ip='192.168.126.5'>
      <hostname>api-int.ocp4.example.com</hostname>
      <hostname>api.ocp4.example.com</hostname>
    </host>
  </dns>
  <ip family='ipv4' address='192.168.126.1' prefix='24'>
    <dhcp>
      <range start='192.168.126.2' end='192.168.126.254'/>
    </dhcp>
  </ip>
  <dnsmasq:options>
    <dnsmasq:option value='address=/api.ocp4.example.com/192.168.126.5'/>
    <dnsmasq:option value='address=/api-int.ocp4.example.com/192.168.126.5'/>
    <dnsmasq:option value='address=/*.apps.ocp4.example.com/192.168.126.5'/>
    <dnsmasq:option value='address=/master0.ocp4.example.com/192.168.126.101'/>
    <dnsmasq:option value='address=/master1.ocp4.example.com/192.168.126.102'/>
    <dnsmasq:option value='address=/master2.ocp4.example.com/192.168.126.103'/>
    <dnsmasq:option value='address=/master0.ocp4.example.com/192.168.126.104'/>
    <dnsmasq:option value='address=/worker1.ocp4.example.com/192.168.126.105'/>
  </dnsmasq:options>
</network>
```

