# docker-swarm-keepalived

[![Build Workflow](https://github.com/lhns/docker-swarm-keepalived/workflows/build/badge.svg)](https://github.com/lhns/docker-swarm-keepalived/actions?query=workflow%3Abuild)
[![Docker Stars](https://img.shields.io/docker/stars/lolhens/keepalived-swarm)](https://hub.docker.com/r/lolhens/keepalived-swarm)
[![Docker Pulls](https://img.shields.io/docker/pulls/lolhens/keepalived-swarm)](https://hub.docker.com/r/lolhens/keepalived-swarm)
[![Docker Image Size](https://img.shields.io/docker/image-size/lolhens/keepalived-swarm)](https://hub.docker.com/r/lolhens/keepalived-swarm)
[![Apache License 2.0](https://img.shields.io/github/license/lhns/docker-swarm-keepalived.svg?maxAge=3600)](https://www.apache.org/licenses/LICENSE-2.0)

Operator for [keepalived](https://github.com/acassen/keepalived) on docker swarm.

Uses [osixia/docker-keepalived](https://github.com/osixia/docker-keepalived).

## Usage

- Enable the "ip_vs" kernel module if not enabled
```sh
lsmod | grep -P '^ip_vs\s' || (echo "modprobe ip_vs" >> /etc/modules && modprobe ip_vs)
```
- Set a different priority for each node
```sh
docker node update node1 --label-add KEEPALIVED_PRIORITY=100
docker node update node2 --label-add KEEPALIVED_PRIORITY=101
docker node update node3 --label-add KEEPALIVED_PRIORITY=102
```
- Deploy the stack

## Docker images

https://github.com/lhns/docker-swarm-keepalived/pkgs/container/keepalived-swarm

## Docker Stack

```yml
version: '3.8'

services:
  keepalived:
    image: ghcr.io/lhns/keepalived-swarm
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - host
    deploy:
      mode: global
      placement:
        constraints: [node.role == manager]
    environment:
      KEEPALIVED_VIRTUAL_IPS: "192.168.1.231, 192.168.1.232"

networks:
  host:
    external: true
    name: host
```

## Helpful Links

- https://github.com/acassen/keepalived
- https://github.com/osixia/docker-keepalived
- https://geek-cookbook.funkypenguin.co.nz/ha-docker-swarm/keepalived/

## License

This project uses the Apache 2.0 License. See the file called LICENSE.
