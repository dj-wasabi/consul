FROM alpine:3.3
MAINTAINER 	Werner Dijkerman <ikben@werner-dijkerman.nl>

ENV CONSUL_VERSION=0.6.4

RUN apk --update add curl bash ca-certificates && \
    curl -Ls https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk && \
    apk add --allow-untrusted /tmp/glibc-2.21-r2.apk && \
    rm -rf /tmp/glibc-2.21-r2.apk /var/cache/apk/*

RUN apk add --no-cache curl && \
    curl -sSLo /tmp/consul.zip https://releases.hashicorp.com/consul/{$CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    unzip -d /bin /tmp/consul.zip && \
    rm -rf /tmp/consul.zip && \
    mkdir -p /consul/data /consul/ui /consul/config && \
    curl -sSLo /tmp/webui.zip https://releases.hashicorp.com/consul/{$CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip && \
    unzip -d /consul/ui /tmp/webui.zip && \
    rm -rf /tmp/webui.zip && \
    addgroup consul && \
    adduser -D -g "" -s /bin/sh -G consul consul && \
    chown -R consul:consul /consul


ADD ./config.json /consul/config/config.json
ONBUILD ADD ./config.json /consul/config/config.json

ADD ./start.sh /bin/start.sh
#ADD ./check-http /bin/check-http
#ADD ./check-cmd /bin/check-cmd

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53 53/udp
VOLUME ["/consul/data"]

ENV SHELL /bin/bash

ENTRYPOINT ["/bin/start.sh"]
CMD []