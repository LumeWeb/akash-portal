FROM caddy:2.9-builder AS builder

RUN xcaddy build \
    --with go.lumeweb.com/caddy-etcd

FROM caddy:2.9-alpine

RUN apk add --no-cache bash

COPY portal /usr/local/bin/portal
COPY Caddyfile /etc/caddy/Caddyfile
COPY Caddyfile.nocluster /etc/caddy/Caddyfile.nocluster
COPY entrypoint.sh /entrypoint.sh
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
