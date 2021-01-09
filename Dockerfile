FROM lolhens/debian-jq

COPY ["entrypoint.sh", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]

CMD osixia/keepalived:2.0.20
