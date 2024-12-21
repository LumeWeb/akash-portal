#!/bin/bash


# Source the retry functionality
. /retry.sh

# Setup database if MySQL is enabled
if [ "$PORTAL__CORE__DB__TYPE" = "mysql" ]; then
    echo "MySQL mode detected"

    echo "Waiting for MySQL to be ready..."
    # Try to connect to MySQL with retries
    retry_command mariadb -h"$PORTAL__CORE__DB__HOST" \
        -P"$PORTAL__CORE__DB__PORT" \
        -u"$PORTAL__CORE__DB__USERNAME" \
        -p"$PORTAL__CORE__DB__PASSWORD" \
        -e "SELECT 1;"

    if [ $? -eq 0 ]; then
        echo "Creating databases if they don't exist..."
        # Create databases with retry
        retry_command mariadb -h"$PORTAL__CORE__DB__HOST" \
            -P"$PORTAL__CORE__DB__PORT" \
            -u"$PORTAL__CORE__DB__USERNAME" \
            -p"$PORTAL__CORE__DB__PASSWORD" \
            -e "CREATE DATABASE IF NOT EXISTS $PORTAL__CORE__DB__NAME;"

        echo "MySQL databases ready"
    else
        echo "Failed to connect to MySQL after multiple attempts"
        exit 1
    fi
else
    echo "SQLite mode detected"
fi

# Validate required env vars when clustering is enabled
if [ "${PORTAL__CORE__CLUSTERED__ENABLED}" = "true" ]; then
    required_vars=(
        "PORTAL__CORE__CLUSTERED__ETCD__ENDPOINTS"
        "PORTAL__CORE__CLUSTERED__ETCD__PREFIX"
        "PORTAL__CORE__CLUSTERED__ETCD__USERNAME"
        "PORTAL__CORE__CLUSTERED__ETCD__PASSWORD"
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