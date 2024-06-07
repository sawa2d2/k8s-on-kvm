# Based on https://rheb.hatenablog.com/entry/sno-on-arm-mac-abi#Containerfile

# Preparation Build
FROM quay.io/centos/centos:stream9-minimal as prep

# ARG
ARG VERSION

# ENV 
ENV VERSION=${VERSION}

# Download binary
RUN microdnf install tar gzip -y 
RUN curl -L https://github.com/okd-project/okd/releases/download/${VERSION}/openshift-install-linux-${VERSION}.tar.gz -o openshift-install-linux.tar.gz
RUN curl -L https://github.com/okd-project/okd/releases/download/${VERSION}/openshift-client-linux-${VERSION}.tar.gz -o openshift-client-linux.tar.gz
RUN tar xzf openshift-install-linux.tar.gz
RUN tar xzf openshift-client-linux.tar.gz

# Build image
FROM quay.io/centos/centos:stream9-minimal as build

RUN microdnf update -y \
&& microdnf install nmstate -y \
&& microdnf clean all

COPY --from=prep openshift-install /usr/local/bin
COPY --from=prep oc /usr/local/bin

ENTRYPOINT ["/usr/local/bin/openshift-install"]
