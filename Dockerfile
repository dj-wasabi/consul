FROM alpine:3.6
MAINTAINER 	Werner Dijkerman <ikben@werner-dijkerman.nl>

ARG CONSUL_USERID

ENV CONSUL_VERSION=0.9.2 \
    CONSUL_USERNAME="consul" \
    CONSUL_USERID=${CONSUL_USERID:-1050}

RUN apk --update --no-cache add tini curl bash libcap openssl python net-tools ca-certificates && \
    rm -rf /var/cache/apk/* && \
    mkdir /consul

ADD ./start-consul.sh /bin/start-consul.sh
ADD ./config.json /consul/config.json

RUN adduser -D -u ${CONSUL_USERID} ${CONSUL_USERNAME} && \
    curl -sSLo /tmp/consul.zip https://releases.hashicorp.com/consul/{$CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    unzip -d /bin /tmp/consul.zip && \
    mkdir -p /consul/data /consul/ui /consul/config && \
    chown -R consul /consul && \
    chmod 644 /consul/config.json && \
    setcap cap_ipc_lock=+ep $(readlink -f /bin/consul) && \
    setcap "cap_net_bind_service=+ep" /bin/consul && \
    chmod +x /bin/start-consul.sh

USER ${CONSUL_USERNAME}

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53 53/udp
VOLUME ["/consul/data", "/consul/config"]

ENV SHELL /bin/bash
ENTRYPOINT ["/sbin/tini", "--", "/bin/start-consul.sh"]
CMD []
