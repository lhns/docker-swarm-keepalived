#!/bin/bash

set -e -o pipefail

nodes_metadata="$(while IFS= read -r node; do docker node inspect "$(echo "$node" | jq -r .ID)" | jq -c --argjson node "$node" '.[]|.+{Self:$node.Self}'; done < <(docker node ls --format '{{json .}}') | jq -sc '')"
node_labels="$(echo "$nodes_metadata" | jq -c 'map(select(.Self))[0].Spec.Labels')"

if [ -z "$KEEPALIVED_INTERFACE" ]; then
  KEEPALIVED_INTERFACE="$(echo "$node_labels" | jq -r '.KEEPALIVED_INTERFACE|select(.!=null)')"
fi
if [ -z "$KEEPALIVED_INTERFACE" ]; then
  KEEPALIVED_INTERFACE="$(ip route get 1 | awk '{print $(NF-4);exit}')"
fi
export KEEPALIVED_INTERFACE

if [ -z "$KEEPALIVED_PASSWORD" ]; then
  KEEPALIVED_PASSWORD='8cteD88Hq4SZpPxm'
fi
export KEEPALIVED_PASSWORD

if [ -z "$KEEPALIVED_PRIORITY" ]; then
  KEEPALIVED_PRIORITY="$(echo "$node_labels" | jq -r '.KEEPALIVED_PRIORITY|select(.!=null)')"
fi
if [ -z "$KEEPALIVED_PRIORITY" ] || (( KEEPALIVED_PRIORITY < 0 || KEEPALIVED_PRIORITY > 255 )); then
  echo "KEEPALIVED_PRIORITY must be set between 0 and 255!" >&2
  exit 1
fi
export KEEPALIVED_PRIORITY

if [ -z "$KEEPALIVED_ROUTER_ID" ]; then
  KEEPALIVED_ROUTER_ID='51'
fi
export KEEPALIVED_ROUTER_ID

if [ -z "$KEEPALIVED_IP" ]; then
  KEEPALIVED_IP="$(echo "$node_labels" | jq -r '.KEEPALIVED_IP|select(.!=null)')"
fi
if [ -z "$KEEPALIVED_IP" ]; then
  KEEPALIVED_IP="$(echo "$nodes_metadata" | jq -r 'map(select(.Self))[0].ManagerStatus.Addr|select(.!=null)|split(":")[0]')"
fi
export KEEPALIVED_IP

if [ -z "$KEEPALIVED_UNICAST_PEERS" ]; then
  KEEPALIVED_UNICAST_PEERS="$(echo "$nodes_metadata" | jq -r 'map(.ManagerStatus.Addr|select(.!=null)|split(":")[0])|join(",")')"
fi
KEEPALIVED_UNICAST_PEERS="$(jq -nr --arg peers "$KEEPALIVED_UNICAST_PEERS" --arg ip "$KEEPALIVED_IP" '$peers|split(",\\s*";"")|map(select(.!=$ip)|"\u0027\(.)\u0027")|join(",")|"#PYTHON2BASH:[\(.)]"')"
export KEEPALIVED_UNICAST_PEERS

KEEPALIVED_VIRTUAL_IPS="$(jq -nr --arg ips "$KEEPALIVED_VIRTUAL_IPS" '$ips|split(",\\s*";"")|map("\u0027\(.)\u0027")|join(",")|"#PYTHON2BASH:[\(.)]"')"
export KEEPALIVED_VIRTUAL_IPS

if [ -z "$KEEPALIVED_NOTIFY" ]; then
  KEEPALIVED_NOTIFY='/container/service/keepalived/assets/notify.sh'
fi
export KEEPALIVED_NOTIFY

if [ -z "$KEEPALIVED_COMMAND_LINE_ARGUMENTS" ]; then
  KEEPALIVED_COMMAND_LINE_ARGUMENTS='--log-detail --dump-conf'
fi
export KEEPALIVED_COMMAND_LINE_ARGUMENTS

if [ -z "$KEEPALIVED_STATE" ]; then
  KEEPALIVED_STATE='BACKUP'
fi
export KEEPALIVED_STATE

if [ -z "$KEEPALIVED_CONTAINER_NAME" ]; then
  container_id="$(cat /proc/self/mountinfo | grep "/docker/containers/" | head -1 | sed -E 's/.*?\/docker\/containers\/([^/]*?).*/\1/')"
  KEEPALIVED_CONTAINER_NAME="keepalived-$container_id"
fi
export KEEPALIVED_CONTAINER_NAME

exec docker run -i --sig-proxy --rm --name "$KEEPALIVED_CONTAINER_NAME" \
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
