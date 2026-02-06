#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Validate .env exists
[[ -f .env ]] || { echo "ERROR: .env not found"; exit 1; }

# Load env vars
set -a
source .env
set +a

# Check required vars
required_vars=(
    DOMAIN
    ACME_EMAIL
    DOCKER_HOST_IP
    PIHOLE_PRIMARY_IP
    PIHOLE_SECONDARY_IP
    SYNOLOGY_IP
    UNIFI_IP
    PROXMOX_IP
    GRAFANA_ADMIN_USER
    GRAFANA_ADMIN_PASSWORD
    TRAEFIK_BASIC_AUTH
    BW_INSTALLATION_ID
    BW_INSTALLATION_KEY
)

for var in "${required_vars[@]}"; do
    [[ -n "${!var:-}" ]] || { echo "ERROR: $var not set in .env"; exit 1; }
done

echo "Generating configs from templates..."

# Generate traefik configs (explicit var whitelist)
envsubst '${ACME_EMAIL}' \
    < traefik/data/traefik.yml.template \
    > traefik/data/traefik.yml

envsubst '${DOMAIN} ${PIHOLE_PRIMARY_IP} ${PIHOLE_SECONDARY_IP} ${SYNOLOGY_IP} ${UNIFI_IP} ${PROXMOX_IP}' \
    < traefik/data/config.yml.template \
    > traefik/data/config.yml

# Generate prometheus config
envsubst '${PIHOLE_PRIMARY_IP} ${PIHOLE_SECONDARY_IP}' \
    < monitoring/config/prometheus/prometheus.yml.template \
    > monitoring/config/prometheus/prometheus.yml

echo "Deploying services..."

for dir in traefik bitwarden monitoring homepage nebula-sync; do
    if [[ -d "$dir" ]]; then
        echo "  $dir..."
        (cd "$dir" && docker compose --env-file ../.env pull --quiet && docker compose --env-file ../.env up -d)
    fi
done

# Reload Prometheus config
curl -sf -X POST http://127.0.0.1:9090/-/reload && echo "  Prometheus config reloaded" || echo "  WARN: Prometheus reload failed"

echo "Done"
