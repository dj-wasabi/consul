FROM alpine:3.4
MAINTAINER 	Werner Dijkerman <ikben@werner-dijkerman.nl>

ENV CONSUL_VERSION=0.6.4

RUN apk --update --no-cache add curl bash ca-certificates && \
    rm -rf /var/cache/apk/*

RUN curl -sSLo /tmp/consul.zip https://releases.hashicorp.com/consul/{$CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    unzip -d /bin /tmp/consul.zip && \
    mkdir -p /consul/data /consul/ui /consul/config && \
    curl -sSLo /tmp/webui.zip https://releases.hashicorp.com/consul/{$CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip && \
    unzip -d /consul/ui /tmp/webui.zip && \
    rm -rf /tmp/webui.zip /tmp/consul.zip

ADD ./config.json /consul/config/config.json
ONBUILD ADD ./config.json /consul/config/config.json

ADD ./start-consul.sh /bin/start-consul.sh

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53 53/udp
VOLUME ["/consul/data"]

ENV SHELL /bin/bash

ENTRYPOINT ["/bin/start-consul.sh"]
CMD []