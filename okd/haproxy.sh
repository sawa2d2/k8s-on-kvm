#!/bin/bash
haproxy_cfg="haproxy.cfg"
if [[ $1 != "" ]]; then
  haproxy_cfg=$1
fi
sudo podman run -it --rm --network=tt0 -p 8080:9000 -v `pwd`/$haproxy_cfg:/etc/haproxy/haproxy.cfg okd-haproxy /bin/bash
