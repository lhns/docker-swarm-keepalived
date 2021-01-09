# docker-swarm-keepalived
Runs keepalived in docker swarm

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
