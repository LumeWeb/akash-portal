FROM ghcr.io/lumeweb/akash-metrics-exporter:develop AS metrics-exporter
FROM caddy:2.9-alpine

RUN apk add --no-cache bash mysql-client mariadb-connector-c

COPY caddy /usr/bin/caddy
COPY portal /usr/local/bin/portal
COPY Caddyfile.cluster /etc/caddy/Caddyfile.cluster
COPY Caddyfile.nocluster /etc/caddy/Caddyfile.nocluster
COPY entrypoint.sh /entrypoint.sh
COPY retry.sh /retry.sh
COPY --from=metrics-exporter /usr/bin/metrics-exporter /usr/bin/akash-metrics-exporter

RUN chmod +x /entrypoint.sh

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

ENTRYPOINT ["/entrypoint.sh"]