#!/bin/bash

# Start portal in background
/usr/local/bin/portal &

# Start Caddy in foreground
/usr/bin/caddy run --config /etc/caddy/Caddyfile
