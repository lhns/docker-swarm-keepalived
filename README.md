# docker-swarm-keepalived
[![Docker Build](https://img.shields.io/docker/cloud/build/lolhens/keepalived-swarm)](https://hub.docker.com/r/lolhens/keepalived-swarm/builds)
[![Docker Stars](https://img.shields.io/docker/stars/lolhens/keepalived-swarm)](https://hub.docker.com/r/lolhens/keepalived-swarm)
[![Docker Pulls](https://img.shields.io/docker/pulls/lolhens/keepalived-swarm)](https://hub.docker.com/r/lolhens/keepalived-swarm)
[![Docker Image Size](https://img.shields.io/docker/image-size/lolhens/keepalived-swarm)](https://hub.docker.com/r/lolhens/keepalived-swarm)
[![Docker Image Layers](https://img.shields.io/microbadger/layers/lolhens/keepalived-swarm)](https://hub.docker.com/r/lolhens/keepalived-swarm)
[![Apache License 2.0](https://img.shields.io/github/license/LolHens/docker-swarm-keepalived.svg?maxAge=3600)](https://www.apache.org/licenses/LICENSE-2.0)

Runs keepalived in docker swarm.

## Docker images
https://hub.docker.com/r/lolhens/keepalived-swarm

## Docker Stack
```yml
version: '3.7'

services:
  keepalived:
    image: lolhens/keepalived-swarm:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker:ro
    networks:
      - host
    deploy:
      mode: global
      placement:
        constraints: [node.role == manager]
    environment:
      KEEPALIVED_UNICAST_PEERS: "192.168.1.10, 192.168.1.11, 192.168.1.12"
      KEEPALIVED_VIRTUAL_IPS: "192.168.1.231, 192.168.1.232"

networks:
  host:
    external: true
    name: host
```

## License
This project uses the Apache 2.0 License. See the file called LICENSE.
