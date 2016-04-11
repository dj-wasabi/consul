# wdijkerman-consul

# Introduction

This is an Docker container for Consul running Alpine. 

The versions in this Docker container:

    * alpine: 3.3
    * consul: 0.6.4

## Versions

- `0.0.1`, `latest` [(Dockerfile)](https://github.com/dj-wasabi/docker-consul/blob/master/Dockerfile)

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
docker run -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h server1 wdijkerman/consul -server -bootstrap -ui-dir /consul/ui
```

## Multinode cluster

According to the official documentation of Consul bu Hashicorp, the best (or optimal) cluster size will be 3 or 5 nodes. The first node in the cluster is started differently than the others. The first node will be started like this:

```bash
docker run -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 wdijkerman/consul -server -bootstrap -ui-dir /consul/ui -bootstrap-expect 3
```

The rest of the nodes are started with the `-join` command. We do need the ip for the first Consul server.

```bash
docker run -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 wdijkerman/consul -server -bootstrap -ui-dir /consul/ui -join <ip_from_first_node>
```

# Configurations

There are a lot of options to configure Consul. See this page for all options: https://www.consul.io/docs/agent/options.html

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
