FROM ubuntu

RUN sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y haproxy net-tools iputils-ping curl nmap telnet \
 && sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/haproxy \
 && rm -rf /var/lib/apt/lists/*

ADD start-haproxy /start-haproxy

VOLUME ["/haproxy-override"]

WORKDIR /etc/haproxy

EXPOSE 6443
EXPOSE 22623
EXPOSE 443
EXPOSE 80

CMD ["/start-haproxy"]
