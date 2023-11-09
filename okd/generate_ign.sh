#!/bin/bash

ign_files=(bootstrap.ign master.ign worker.ign)

for file in "${ign_files[@]}"; do
  if [ -f "$file" ]; then
    echo "Error: bootstrap.ign, master.ign, or worker.ign already exists."
    echo "  Clean them up in advance."
    exit 1
  fi
done

cp install-config.yaml.backup install-config.yaml

openshift-install create manifests

cat <<EOF > ./manifests/okd-configure-master-node-dns.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: okd-configure-master-node-dns
spec:
  config:
    ignition:
      version: 3.3.0
    storage:
      links:
      - path: /etc/resolv.conf
        overwrite: true
        target: ../run/systemd/resolve/resolv.conf
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,W1Jlc29sdmVdCkROU1N0dWJMaXN0ZW5lcj1ubwo=
        mode: 420
        overwrite: true
        path: /etc/systemd/resolved.conf.d/50-no-dns-stub.conf
EOF

openshift-install create ignition-configs

