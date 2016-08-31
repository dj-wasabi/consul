# wdijkerman-consul

![Docker Stars](https://img.shields.io/docker/stars/wdijkerman/consul.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/wdijkerman/consul.svg) [![](https://images.microbadger.com/badges/image/wdijkerman/consul.svg)](https://microbadger.com/images/wdijkerman/consul "Get your own image badge on microbadger.com") [![Build Status](https://travis-ci.org/dj-wasabi/docker-consul.svg?branch=master)](https://travis-ci.org/dj-wasabi/docker-consul) 

# Introduction

This is an Docker container for Consul running on Alpine. The container is very small, a little but more than 65MB in size.

The versions in this Docker container:

* alpine: 3.4
* consul: 0.6.4

The consul application is installed in the /bin directory in the container, so is the start script. There data from Consul is in the /consul directory:

* /consul/ui
* /consul/config
* /consul/data

*/consul/ui*
This is the location of the User interface files. 

*/consul/config*
The location of the config.json file. This is also an volume, so this can be mounted on the host.

*/consul/data*
The location where Consul will store all data. This is also an volume, so this can be mounted on the host.

## why another version?

At the moment, the `progrium/consul` is currently the most popular container running Consul. The only problem (for me) is that it uses an older version of Consul (0.5.2). Also this is an learning opportunity for me to make Docker containers. :-) 

## Versions

- `0.0.1`,  [(Dockerfile)](https://github.com/dj-wasabi/docker-consul/blob/master/Dockerfile)
- `0.0.2`, `latest` [(Dockerfile)](https://github.com/dj-wasabi/docker-consul/blob/master/Dockerfile)

# Install the container

Just run the following command to download the container:

```bash
docker pull wdijkerman/consul
```

# Using the container

There are several ways to use this container.

## Single node (Cluster) server

This example will boot an single node Consul server, without any agents.

```bash
docker run  -p 8400:8400 -p 8500:8500 \
            -p 8600:53/udp -h server1 \
            wdijkerman/consul -server \
            -bootstrap -ui -ui-dir /consul/ui
```

## Multi node cluster

According to the official documentation of Consul bu Hashicorp, the best (or optimal) cluster size will be 3 or 5 nodes. The first node in the cluster is started differently than the others. The first node will be started like this:

```bash
docker run  -p 8300-8302:8300-8302 \
            -p 8301-8302:8301-8302/udp \
            -p 8400:8400 -p 8500:8500 \
            -p 8600:53 -p 8600:53/udp \
            -v /data/consul/cluster:/consul/data \
            -v /data/consul/config:/consul/config \
            -h server1 wdijkerman/consul \
            -server -ui -ui-dir /consul/ui \
            -bootstrap-expect 3
```

As you see, we started the Consul cluster with the `-bootstrap-expect 3` option. We let the Consul Cluster know that the size will be 3 `server` nodes. It doesn't matter how many agent nodes it use.
We have an local directory '/data/consul/cluster' that will be mounted in the container, so no Consul data is lost when the container is restarted.

The rest of the nodes are started with the `-join` command. We do need the ip for the first Consul server first.

```bash
docker run  -p 8300-8302:8300-8302 \
            -p 8301-8302:8301-8302/udp \
            -p 8400:8400 -p 8500:8500 \
            -p 8600:53 -p 8600:53/udp \
            -v /data/consul/cluster:/consul/data \
            -v /data/consul/config:/consul/config \
            -h server[2-5] wdijkerman/consul \
            -server -ui -ui-dir /consul/ui \
            -join <ip_from_first_node>
```

The rest of the server will initially connect to the first booted server and will join the cluster. 

## Agent

When we have an Consul cluster, we can add agents to the cluster. They will handle the requests from other docker services

```bash
docker run  -p 8301-8302:8301-8302 \
            -p 8301-8302:8301-8302/udp \
            -p 8400:8400 -p 8500:8500 \
            -p 8600:53 -p 8600:53/udp \
            -h agent[1-??] wdijkerman/consul \
            -join <ip_from_first_node>
```


# Configurations

There are a lot of options to configure Consul. See this page for all options: https://www.consul.io/docs/agent/options.html
You can add the options in the command line, see the following example:

```bash
docker run  -p 8301-8302:8301-8302 \
            -p 8301-8302:8301-8302/udp \
            -p 8400:8400 -p 8500:8500 \
            -p 8600:53 -p 8600:53/udp \
            -h agent[1-??] wdijkerman/consul \
            -join <ip_from_first_node> \
            -advertise 10.0.0.2
```

In the configuration you see above, we have added the `-advertise` configuration option.

# Ports

Consul requires up to 5 different ports to work properly, some on TCP, UDP, or both protocols. Below we document the requirements for each port.

* Server RPC (Default 8300). This is used by servers to handle incoming requests from other agents. TCP only.
* Serf LAN (Default 8301). This is used to handle gossip in the LAN. Required by all agents. TCP and UDP.
* Serf WAN (Default 8302). This is used by servers to gossip over the WAN to other servers. TCP and UDP.
* CLI RPC (Default 8400). This is used by all agents to handle RPC from the CLI. TCP only.
* HTTP API (Default 8500). This is used by clients to talk to the HTTP API. TCP only.
* DNS Interface (Default 8600). Used to resolve DNS queries. TCP and UDP.

# License

The MIT License (MIT)

See file: License

# Issues

Please report issues at https://github.com/dj-wasabi/docker-consul/issues 

Pull Requests are welcome!
