#!/bin/bash

# Validate required env vars when clustering is enabled
if [ "${PORTAL_CORE_CLUSTERED_ENABLED}" = "true" ]; then
    required_vars=(
        "PORTAL_CORE_CLUSTERED_ETCD_ENDPOINTS"
        "PORTAL_CORE_CLUSTERED_ETCD_PREFIX"
    )
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "Error: $var is required when clustering is enabled"
            exit 1
        fi
    done

    # Remove TLS block from Caddyfile if TLS env vars are empty
    if [ -z "${PORTAL_CORE_CLUSTERED_ETCD_TLS_CERT}" ] || [ -z "${PORTAL_CORE_CLUSTERED_ETCD_TLS_KEY}" ]; then
        sed -i '/tls/,/}/d' /etc/caddy/Caddyfile
        sed -i '/^$/d' /etc/caddy/Caddyfile
    fi

    # Start portal in background
    /usr/local/bin/portal &

    # Start Caddy with etcd storage in foreground
    /usr/bin/caddy run --config /etc/caddy/Caddyfile
else
    # Start portal in background
    /usr/local/bin/portal &

    # Start Caddy without etcd storage in foreground
    /usr/bin/caddy run --config /etc/caddy/Caddyfile.nocluster
fi
