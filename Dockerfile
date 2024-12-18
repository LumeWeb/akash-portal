FROM caddy:2.9-alpine

RUN apk add --no-cache bash

COPY portal /usr/local/bin/portal
COPY Caddyfile /etc/caddy/Caddyfile
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
