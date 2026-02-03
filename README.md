# Docker Stack

Self-hosted services on a single Docker host.

## Services

| Service | Purpose | Version |
|---------|---------|---------|
| traefik | Reverse proxy + SSL | v3.3.3 |
| bitwarden | Password manager | 2025.12.2 |
| prometheus | Metrics collection | v3.2.1 |
| grafana | Dashboards | 11.5.2 |
| node_exporter | Host metrics | v1.9.0 |
| homepage | Dashboard | v1.2.0 |
| nebula-sync | Pi-hole sync | v1.3.0 |

## Setup

### 1. Clone and configure

```bash
cd ~/docker-apps  # or wherever you want it

# Copy .env.example and fill in values
cp .env.example .env
vim .env
```

### 2. Copy secrets (not in git)

```bash
# Traefik Cloudflare token
mkdir -p traefik/data
cp /path/to/cf_api_token.txt traefik/data/

# Nebula-sync Pi-hole credentials
mkdir -p nebula-sync/secrets
cp /path/to/primary.txt nebula-sync/secrets/
cp /path/to/replicas.txt nebula-sync/secrets/

# Homepage config (has API keys)
mkdir -p homepage/config
cp /path/to/homepage-config/* homepage/config/
```

### 3. Create network and deploy

```bash
docker network create proxy
./scripts/deploy.sh
```

## Environment Variables

All secrets live in `.env` (never committed):

```bash
DOMAIN=              # e.g., home.example.com
ACME_EMAIL=          # For Let's Encrypt

# Internal IPs
DOCKER_HOST_IP=
PIHOLE_PRIMARY_IP=
PIHOLE_SECONDARY_IP=
SYNOLOGY_IP=
UNIFI_IP=
PROXMOX_IP=

# Service credentials
TRAEFIK_BASIC_AUTH=
GRAFANA_ADMIN_USER=
GRAFANA_ADMIN_PASSWORD=
BW_INSTALLATION_ID=
BW_INSTALLATION_KEY=
```

## Templates

Config files with IPs/domains use templates + `envsubst`:

| Template | Generated | Variables |
|----------|-----------|-----------|
| `traefik/data/traefik.yml.template` | `traefik.yml` | `ACME_EMAIL` |
| `traefik/data/config.yml.template` | `config.yml` | `DOMAIN`, `*_IP` |
| `monitoring/config/prometheus/prometheus.yml.template` | `prometheus.yml` | `*_IP` |

The deploy script generates these automatically.

## What's NOT in git

- `.env` - all secrets
- `traefik/data/traefik.yml` - generated
- `traefik/data/config.yml` - generated
- `traefik/data/acme.json` - SSL certs
- `traefik/data/cf_api_token.txt` - Cloudflare API
- `monitoring/config/prometheus/prometheus.yml` - generated
- `homepage/config/` - contains API keys
- `nebula-sync/secrets/` - Pi-hole credentials
- `*/data/` - persistent volumes

## Deploy

```bash
# Full deploy (generates configs + restarts all)
./scripts/deploy.sh

# Single service
cd traefik && docker compose up -d

# Update images
cd bitwarden && docker compose pull && docker compose up -d
```

## Renovate

This repo uses [Renovate](https://github.com/apps/renovate) to open PRs when Docker images have updates. Review and merge manually, then deploy.

## Verify before pushing

```bash
./scripts/verify-no-secrets.sh
gitleaks detect --source . --no-git
```
