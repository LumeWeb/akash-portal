FROM caddy:2.9-alpine

RUN apk add --no-cache bash mysql-client mariadb-connector-c

COPY caddy /usr/bin/caddy
COPY portal /usr/local/bin/portal
COPY Caddyfile.cluster /etc/caddy/Caddyfile.cluster
COPY Caddyfile.cluster.notls /etc/caddy/Caddyfile.cluster.notls
COPY Caddyfile.nocluster /etc/caddy/Caddyfile.nocluster
COPY entrypoint.sh /entrypoint.sh
COPY retry.sh /retry.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]