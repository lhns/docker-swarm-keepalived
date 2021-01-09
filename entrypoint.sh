#!/bin/bash

set -eo pipefail

node_labels="$(docker node inspect "$(docker node ls | awk '$2 == "*" {print $1}')" | jq -c '.[].Spec.Labels')"

if [ -z "$KEEPALIVED_INTERFACE" ]; then
  export KEEPALIVED_INTERFACE="$(echo "$node_labels" | jq -r '.KEEPALIVED_INTERFACE // ""')"
fi

if [ -z "$KEEPALIVED_INTERFACE" ]; then
  export KEEPALIVED_INTERFACE="$(ip route get 1 | awk '{print $(NF-4);exit}')"
fi

if [ -z "$KEEPALIVED_PASSWORD" ]; then
  export KEEPALIVED_PASSWORD='8cteD88Hq4SZpPxm'
fi

if [ -z "$KEEPALIVED_PRIORITY" ]; then
  export KEEPALIVED_PRIORITY="$(echo "$node_labels" | jq -r '.KEEPALIVED_PRIORITY // ""')"
fi

if [ -z "$KEEPALIVED_PRIORITY" ]; then
  export KEEPALIVED_PRIORITY='150'
fi

if [ -z "$KEEPALIVED_ROUTER_ID" ]; then
  export KEEPALIVED_ROUTER_ID='51'
fi

if [ -z "$KEEPALIVED_IP" ]; then
  export KEEPALIVED_IP="$(ip route get 1 | awk '{print $(NF-2);exit}')"
fi

if [ -z "$KEEPALIVED_UNICAST_PEERS" ]; then
  export KEEPALIVED_UNICAST_PEERS="$(docker node inspect $(docker node ls | tail -n +2 | awk '{print $1}') | jq -sr 'map(.[].ManagerStatus.Addr|select(.!=null)|split(":")[0])|join(",")')"
fi

export KEEPALIVED_UNICAST_PEERS="$(jq -nr --arg peers "$KEEPALIVED_UNICAST_PEERS" --arg ip "$KEEPALIVED_IP" '$peers|split(",\\s*";"")|map(select(.!=$ip)|"\u0027\(.)\u0027")|join(",")|"#PYTHON2BASH:[\(.)]"')"

export KEEPALIVED_VIRTUAL_IPS="$(jq -nr --arg ips "$KEEPALIVED_VIRTUAL_IPS" '$ips|split(",\\s*";"")|map("\u0027\(.)\u0027")|join(",")|"#PYTHON2BASH:[\(.)]"')"

if [ -z "$KEEPALIVED_NOTIFY" ]; then
  export KEEPALIVED_NOTIFY='/container/service/keepalived/assets/notify.sh'
fi

if [ -z "$KEEPALIVED_COMMAND_LINE_ARGUMENTS" ]; then
  export KEEPALIVED_COMMAND_LINE_ARGUMENTS='--log-detail --dump-conf'
fi

if [ -z "$KEEPALIVED_STATE" ]; then
  export KEEPALIVED_STATE='BACKUP'
fi

exec docker run -i --rm --name keepalived \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_BROADCAST \
  --cap-add=NET_RAW \
  -e KEEPALIVED_INTERFACE \
  -e KEEPALIVED_PASSWORD \
  -e KEEPALIVED_PRIORITY \
  -e KEEPALIVED_ROUTER_ID \
  -e KEEPALIVED_UNICAST_PEERS \
  -e KEEPALIVED_VIRTUAL_IPS \
  -e KEEPALIVED_NOTIFY \
  -e KEEPALIVED_COMMAND_LINE_ARGUMENTS \
  -e KEEPALIVED_STATE \
  "$1"
