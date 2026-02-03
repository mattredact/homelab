# Homelab Docker Stack

Self-hosted services running on a single Docker host behind Traefik.

## Services

- **Traefik** - Reverse proxy with automatic SSL via Cloudflare DNS
- **Bitwarden** - Self-hosted password manager (Lite/Vaultwarden)
- **Prometheus** - Metrics collection
- **Grafana** - Dashboards and visualization
- **Node Exporter** - Host metrics
- **Homepage** - Service dashboard
- **Nebula-sync** - Pi-hole configuration sync

## Quick Start

```bash
git clone https://github.com/mattredact/homelab.git
cd homelab

# Configure environment
cp .env.example .env
vim .env  # Fill in all values

# Add secrets (not in git)
mkdir -p traefik/data nebula-sync/secrets homepage/config
# Copy cf_api_token.txt, primary.txt, replicas.txt, homepage config

# Create network and deploy
docker network create proxy
./scripts/deploy.sh
```

## Configuration

All sensitive values use environment variables from `.env`:

```
DOMAIN                  # Your domain (e.g., home.example.com)
ACME_EMAIL              # Let's Encrypt email
DOCKER_HOST_IP          # Docker host IP
PIHOLE_PRIMARY_IP       # Primary Pi-hole
PIHOLE_SECONDARY_IP     # Secondary Pi-hole
SYNOLOGY_IP             # NAS IP
UNIFI_IP                # UniFi controller
PROXMOX_IP              # Proxmox host
GRAFANA_ADMIN_USER      # Grafana admin username
GRAFANA_ADMIN_PASSWORD  # Grafana admin password
TRAEFIK_BASIC_AUTH      # htpasswd string for Traefik dashboard
BW_INSTALLATION_ID      # Bitwarden installation ID
BW_INSTALLATION_KEY     # Bitwarden installation key
```

Template files (`*.template`) are processed by `deploy.sh` using `envsubst`.

## Deployment

```bash
# Full deploy
./scripts/deploy.sh

# Single service (from repo root)
source .env && cd monitoring && docker compose up -d
```

## Updates

[Renovate](https://github.com/apps/renovate) opens PRs when new image versions are available. Review, merge, then:

```bash
git pull && ./scripts/deploy.sh
```

## Security

Run before pushing:

```bash
./scripts/verify-no-secrets.sh
```
