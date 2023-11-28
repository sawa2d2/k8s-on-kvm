# HAProxy

## Prerequisites
- `podman`v4
- `containernetworking-plugins`

## Pereparation

Edit `/etc/containers/containers.conf` to use CNI for network backend of podman:
```
[network]
network_backend = "cni"
```

Copy [`tt0.conflist`](./tt0.conflist) to `/etc/cni/net.d`.

Check if the network `tt0` is available:
```
$ podman network ls
NETWORK ID    NAME        DRIVER
2f259bab93aa  podman      bridge
f8cd3888f1a0  tt0         bridge
```

## Start an HAProxy container
```
sudo podman build -t okd-haproxy .
sudo podman run -it --rm --network=tt0 -p 8080:9000 -v `pwd`/haproxy.cfg:/etc/haproxy/haproxy.cfg:ro okd-haproxy /bin/bash

# Inside container
/start-haproxy
```

## Related links
- [Network containers | Docker Docs](https://docs.docker.com/engine/tutorials/networkingcontainers/)
- [Networking between KVM VM and docker container on same host - Server Fault](https://serverfault.com/questions/948339/networking-between-kvm-vm-and-docker-container-on-same-host)
