# wdijkerman/consul

![Docker Stars](https://img.shields.io/docker/stars/wdijkerman/consul.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/wdijkerman/consul.svg) [![](https://images.microbadger.com/badges/image/wdijkerman/consul.svg)](https://microbadger.com/images/wdijkerman/consul "Get your own image badge on microbadger.com") [![Build Status](https://travis-ci.org/dj-wasabi/docker-consul.svg?branch=master)](https://travis-ci.org/dj-wasabi/docker-consul) 

## Introduction

This is an Docker container for Consul running on Alpine. The container is small, a little bit more than 75MB in size.

The versions in this Docker container:

* alpine: 3.5
* consul: 0.7.2
* python: 2.7.13

### Volumes
The consul application is installed in the /bin directory in the container, so is the start script. There data from Consul is in the /consul directory:

* /consul/config
* /consul/data

*/consul/config*
The location of the config.json file. This is also an volume, so this can be mounted on the host.

*/consul/data*
The location where Consul will store all data. This is also an volume, so this can be mounted on the host.

### User

Consul is running as user consul. With the following capabilities (which are configured in this container)it should be no problem running Consul as non-root user:

- cap_ipc_lock (Should not swap. Also `--cap-add IPC_LOCK` should be added to the command line when to start the Consul Server)
- cap_net_bind_service (Can bind service <1023 as non root user)

The UID used in this container is 995. So make sure the id is already available on the host running the container when host mounts are used.

### Versions

- `0.0.1`,  [(Dockerfile)](https://github.com/dj-wasabi/consul/blob/df23223d6a796bf32400ea652f81b5d8daad8a42/Dockerfile)
- `0.0.2`,  [(Dockerfile)](https://github.com/dj-wasabi/consul/blob/19f77a25940ce72f1f708ed5c93ffa64355606f2/Dockerfile)
- `0.0.3`,  [(Dockerfile)](https://github.com/dj-wasabi/consul/blob/3765e14486a8dcf371f23784300687130c70ea95/Dockerfile)
- `0.7.2`,  [(Dockerfile)](https://github.com/dj-wasabi/consul/blob/beb68930fd9851d29ef63c67b89725ba8083a534/Dockerfile)
- `0.7.3`, `latest` [(Dockerfile)](https://github.com/dj-wasabi/docker-consul/blob/master/Dockerfile)

The version of this container will be the same as the version of Consul, beginning with Consul 0.7.2. 

### Python?

Python is also installed in the container. Python is used for testing the container, which is done with the tool `testinfra`.
You can see in the `tests` directory a file named `test_consul.py` which will be executed. (Still WiP)

## Install the container

Just run the following command to download the container:

```bash
docker pull wdijkerman/consul
```

## Using the container

There are several ways to use this container.

### Single node (Cluster) server

This example will boot an single node Consul server, without any agents.

```bash
docker run  -p 8400:8400 -p 8500:8500 \
            -p 8600:53/udp -h server1 \
            wdijkerman/consul -server \
            -bootstrap -ui -ui-dir /consul/ui
```

### Multi node cluster

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
We have an local directory '/data/consul/cluster' that will be mounted in the container, so no Consul data is lost when the container is restarted. (Make sure the UID of the directories are set to 995)

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

### Agent

When we have an Consul cluster, we can add agents to the cluster. They will handle the requests from other docker services

```bash
docker run  -p 8301-8302:8301-8302 \
            -p 8301-8302:8301-8302/udp \
            -p 8400:8400 -p 8500:8500 \
            -p 8600:53 -p 8600:53/udp \
            -h agent[1-??] wdijkerman/consul \
            -join <ip_from_first_node>
```

## Configurations

There are a lot of options to configure Consul. See this page for all options: https://www.consul.io/docs/agent/options.html

### Add commandline

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

### Add configuration file

You can also add a json configuration file. Place the json file in the `/data/consul/config` directory (Or use the directory which you use for storing configuration). 

```
cat /data/consul/config/datacenter.json 
{
  "datacenter": "nwg"
}
```

When Consul is restarted, you'll see that the datacenter is set to "nwg".

```
==> Starting Consul agent...
==> Starting Consul agent RPC...
==> Consul agent running!
           Version: 'v0.7.2'
         Node name: 'server1'
        Datacenter: 'nwg'
            Server: true (bootstrap: true)
       Client Addr: 0.0.0.0 (HTTP: 8500, HTTPS: -1, DNS: 53, RPC: 8400)
      Cluster Addr: 172.17.0.2 (LAN: 8301, WAN: 8302)
    Gossip encrypt: false, RPC-TLS: false, TLS-Incoming: false
             Atlas: <disabled>
```

## Ports

Consul requires up to 5 different ports to work properly, some on TCP, UDP, or both protocols. Below we document the requirements for each port.

* Server RPC (Default 8300). This is used by servers to handle incoming requests from other agents. TCP only.
* Serf LAN (Default 8301). This is used to handle gossip in the LAN. Required by all agents. TCP and UDP.
* Serf WAN (Default 8302). This is used by servers to gossip over the WAN to other servers. TCP and UDP.
* CLI RPC (Default 8400). This is used by all agents to handle RPC from the CLI. TCP only.
* HTTP API (Default 8500). This is used by clients to talk to the HTTP API. TCP only.
* DNS Interface (Default 8600). Used to resolve DNS queries. TCP and UDP.

## License

The MIT License (MIT)

See file: License

## Issues

Please report issues at https://github.com/dj-wasabi/consul/issues 

Pull Requests are welcome!
