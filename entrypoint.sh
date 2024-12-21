#!/bin/bash

# Validate required env vars when clustering is enabled
if [ "${PORTAL__CORE__CLUSTERED__ENABLED}" = "true" ]; then
    required_vars=(
        "PORTAL__CORE__CLUSTERED__ETCD__ENDPOINTS"
        "PORTAL__CORE__CLUSTERED__ETCD__PREFIX"
    )
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "Error: $var is required when clustering is enabled"
            exit 1
        fi
    done

    # Start portal in background
    /usr/local/bin/portal -env &

    # Choose appropriate Caddyfile based on TLS configuration
    if [ -z "${PORTAL__CORE__CLUSTERED__ETCD__TLS_CERT}" ] || [ -z "${PORTAL__CORE__CLUSTERED__ETCD_TLS_KEY}" ]; then
        echo "Starting Caddy with cluster config (no TLS)"
        /usr/bin/caddy run --config /etc/caddy/Caddyfile.cluster.notls
    else
        echo "Starting Caddy with cluster config (with TLS)"
        /usr/bin/caddy run --config /etc/caddy/Caddyfile.cluster
    fi
else
    # Start portal in background
    /usr/local/bin/portal -env &

    echo "Starting Caddy without clustering"
    /usr/bin/caddy run --config /etc/caddy/Caddyfile.nocluster
fi