#!/bin/bash

KUBESPRAY_DIR=/tmp/kubespray
KUBESPRAY_VERSION=v2.23.0
rm -rf $KUBESPRAY_DIR
git clone git@github.com:kubernetes-sigs/kubespray.git $KUBESPRAY_DIR

cd $KUBESPRAY_DIR
git checkout $KUBESPRAY_VERSION
cd ./contrib/offline

# Select container runtime
if command -v nerdctl 1>/dev/null 2>&1; then
    runtime="nerdctl"
elif command -v podman 1>/dev/null 2>&1; then
    runtime="podman"
elif command -v docker 1>/dev/null 2>&1; then
    runtime="docker"
else
    echo "No supported container runtime found"
    exit 1
fi
# Generate files / images list
sed -i '' 's/\(ansible-playbook\)/\1 -e "ansible-system=linux"/g' generate_list.sh
./generate_list.sh

# Start HTTP server
"${runtime}" kill nginx >/dev/null 2>&1
"${runtime}" rm nginx >/dev/null 2>&1
sed -i '' 's@\(--volume \"\)@\1/mnt/@g' manage-offline-files.sh
./manage-offline-files.sh
