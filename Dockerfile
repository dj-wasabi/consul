FROM alpine:3.4
MAINTAINER 	Werner Dijkerman <ikben@werner-dijkerman.nl>

ENV CONSUL_VERSION=0.7.1 \
    CONSUL_USERNAME="consul" \
    CONSUL_USERID=995

RUN apk --update --no-cache add tini curl bash libcap openssl python net-tools ca-certificates && \
    rm -rf /var/cache/apk/*

ADD ./start-consul.sh /bin/start-consul.sh

RUN adduser -D -u ${CONSUL_USERID} ${CONSUL_USERNAME} && \
    curl -sSLo /tmp/consul.zip https://releases.hashicorp.com/consul/{$CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    unzip -d /bin /tmp/consul.zip && \
    mkdir -p /consul/data /consul/ui /consul/config && \
    curl -sSLo /tmp/webui.zip https://releases.hashicorp.com/consul/{$CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip && \
    unzip -d /consul/ui /tmp/webui.zip && \
    rm -rf /tmp/webui.zip /tmp/consul.zip && \
    chown -R consul /consul && \
    setcap cap_ipc_lock=+ep $(readlink -f $(which consul)) && \
    setcap "cap_net_bind_service=+ep" /bin/consul && \
    chmod +x /bin/start-consul.sh

USER ${CONSUL_USERNAME}

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53 53/udp

VOLUME ["/consul/data"]
VOLUME ["/consul/config"]

ENV SHELL /bin/bash

ENTRYPOINT ["/sbin/tini", "--", "/bin/start-consul.sh"]
CMD []
