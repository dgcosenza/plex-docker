# Plex Media Server Runtime Wrapper on Debian 13 (trixie)

[![CI](https://github.com/dgcosenza/plex-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/plex-docker/actions/workflows/daily.yml)
[![Docker Hub Pulls](https://img.shields.io/docker/pulls/dgcosenza/plex?label=docker%20pulls)](https://hub.docker.com/r/dgcosenza/plex)
[![Image Size](https://img.shields.io/docker/image-size/dgcosenza/plex/latest?label=image%20size)](https://hub.docker.com/r/dgcosenza/plex)
[![License](https://img.shields.io/github/license/dgcosenza/plex-docker)](LICENSE)

A hardened, continuously rebuilt **Debian 13 (`trixie-slim`) runtime-installer wrapper** for **Plex Media Server** with `tini` PID 1, SHA-1 verified startup package retrieval directly from `plex.tv`, non-root daemon execution (`plex`, UID/GID `1000:1000`), and drop-in compatibility with `plexinc/pms-docker`.

> **Licensing & Redistribution Notice:** Plex Media Server is proprietary software governed by the [Plex Terms of Service](https://www.plex.tv/about/privacy-legal/plex-terms-of-service/), which prohibits third-party redistribution of Plex binaries. **This image contains zero proprietary Plex binaries.** At container startup, `/init` fetches the official Debian package directly from `downloads.plex.tv`, verifies its SHA-1 checksum against the official `plex.tv` manifest, caches it in `/config/.pms-deb-cache`, installs it locally in the running container, and launches Plex Media Server as the non-root `plex` user.

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Current Versions

<!-- versions:start -->
_Last verified build: **2026-11-24** (UTC)_

| Component | Resolved Version |
|-----------|------------------|
| Wrapper Base OS | Debian `13` (`debian:trixie-slim`) |
| Latest Smoke-Tested PMS Release (runtime-fetched) | `1.43.5.11079-b3b13e506` |
| Proprietary Binaries in Published Image | **None (0)** |
| Fixable Critical/High (Trivy / Grype) | `0` / `0` |

**Recent upstream updates:**
- Initial hardened Debian 13 runtime-installer wrapper verified against Plex Media Server 1.43.5.
<!-- versions:end -->

## Supported Tags

| Tag | Description |
|-----|-------------|
| `latest` | Moving tag tracking the newest verified daily wrapper build |
| `<pms-version>` | Latest wrapper build tested against the listed public PMS release (e.g. `1.43.5.11079`) |
| `<pms-version>-YYYYMMDD` | Immutable date-stamped build |
| `sha-<short>` | Immutable commit-stamped build |

## Quick Start

### Docker CLI

```bash
docker run -d --name plex \
  --security-opt no-new-privileges:true \
  --network host \
  -e TZ=UTC \
  -e PLEX_UID=1000 \
  -e PLEX_GID=1000 \
  -v ./config:/config/Library/Application\ Support/Plex\ Media\ Server \
  -v ./tmp:/tmp \
  -v ./media:/media:ro \
  dgcosenza/plex:latest
```

### Docker Compose

```yaml
services:
  plex:
    image: dgcosenza/plex:latest
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    network_mode: host
    environment:
      - TZ=UTC
      - PLEX_UID=1000
      - PLEX_GID=1000
      - CHANGE_CONFIG_DIR_OWNERSHIP=true
    volumes:
      - ./config:/config/Library/Application Support/Plex Media Server
      - ./tmp:/tmp
      - ./media:/media:ro
    healthcheck:
      test: ["CMD-SHELL", "/healthcheck.sh || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 3m
```

See [docker-compose.example.yml](docker-compose.example.yml) for a full example.

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `VERSION` | `public` (latest public release), `plexpass` / `beta` (requires `PLEX_TOKEN`), or `docker` (skip download if already installed) | `public` |
| `PLEX_UID` / `PLEX_GID` | UID/GID used to run Plex Media Server and own `/config` | `1000` / `1000` |
| `CHANGE_CONFIG_DIR_OWNERSHIP` | Set to `false` to skip `chown` on `/config` and `/transcode` | `true` |
| `PLEX_TOKEN` | Optional Plex Pass token for `plexpass` channel lookups | — |
| `ADVERTISE_IP` | Custom server connection URLs written to `Preferences.xml` | — |
| `ALLOWED_NETWORKS` | Networks allowed without auth in `Preferences.xml` | — |
| `TZ` | Container timezone | `UTC` |

### Volumes

| Path | Purpose |
|------|---------|
| `/config` | Plex configuration root (also caches the verified `.deb` under `/config/.pms-deb-cache`) |
| `/config/Library/Application Support/Plex Media Server` | Existing PMS database, metadata, and `Preferences.xml` |
| `/transcode` | Temporary transcode scratch directory |
| `/media` | Media libraries |

### Ports

- `32400/tcp` — Primary Plex Media Server HTTP/HTTPS port
- `8324/tcp`, `32469/tcp`, `1900/udp`, `32410-32414/udp` — Optional discovery / DLNA / GDM ports (host network mode)

### User, UID, and GID

- `/init` runs briefly as `root` solely to install the verified Debian `.deb` into `/usr/lib/plexmediaserver` and apply optional ownership adjustments, then drops privileges via `setpriv` to non-root **`plex` (UID 1000 / GID 1000)** before `exec`ing `Plex Media Server`.

### Healthcheck

```bash
/healthcheck.sh
```

Probes `http://127.0.0.1:32400/identity` via `curl -q` (ignoring any user `~/.curlrc` inside `/config`).

## Upgrade and Migration from `plexinc/pms-docker`

1. Back up your Plex database directory (`/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases`) before switching.
2. Keep all existing volume mounts (`/config/Library/Application Support/Plex Media Server`, `/tmp`, `/media/*`), `network_mode: host`, and `/healthcheck.sh` unchanged.
3. Ensure your container has outbound HTTPS access to `plex.tv` and `downloads.plex.tv` on startup so the official Debian `.deb` can be downloaded and SHA-1 verified.
4. Tag the outgoing image locally for rollback, switch `image:` to `dgcosenza/plex:latest` (or pinned `@sha256:...`), and run `docker compose up -d plex`.

## Security

- **Trivy** (OS + packages): SARIF uploaded to GitHub Code Scanning; table and JSON reports retained for 90 days; **blocking hard gate** on 0 fixable `CRITICAL`/`HIGH` findings.
- **Grype**: **blocking hard gate** (`only-fixed: true`, severity cutoff `high`); table report retained for 90 days.
- **SBOM & Provenance**: SPDX-JSON SBOM (Syft) and provenance JSON retained for 90 days.
- **Integrity**: Runtime `.deb` downloads are strictly verified against the official SHA-1 checksum published in `https://plex.tv/api/downloads/5.json` before `dpkg -i`.
- **Non-root daemon**: `Plex Media Server` always runs as unprivileged `plex` (`1000:1000`), compatible with `security_opt: [no-new-privileges:true]`.

See [SECURITY.md](SECURITY.md) for responsible disclosure.

## Build Locally

```bash
docker buildx build --platform linux/amd64 --load -t dgcosenza/plex:local .
```

## Update Policy

Every day at **05:47 UTC** (and on push to `main`, pull requests, or manual dispatch), `.github/workflows/daily.yml` runs a 7-step automated pipeline gated by `.github/scripts/public-check.sh`:

1. **Upstream check:** Queries `https://plex.tv/api/downloads/5.json` for the latest public Linux Debian release metadata, diffs against `versions.json`, and saves `upstream-changes.md` as a 90-day artifact.
2. **Clean rebuild:** Rebuilds the minimal `debian:trixie-slim` wrapper image with `--no-cache` on scheduled runs and `apt-get upgrade`, generating SPDX-JSON SBOM and provenance artifacts.
3. **Vulnerability fix & hard gates:** Runs Trivy (table, JSON, SARIF upload, and blocking 0 fixable `CRITICAL`/`HIGH` gate) and Grype (blocking 0 fixable `CRITICAL`/`HIGH` gate), retaining all reports for 90 days.
4. **Functional smoke test:** Executes `tests/smoke.sh` to assert zero proprietary binaries exist in the built image, verify live download + SHA-1 verification + install + non-root UID 1000 startup + `/identity` HTTP 200 XML, and confirm negative healthcheck failure.
5. **Registry publish:** Pushes `latest`, `<version>`, `<version>-<YYYYMMDD>`, and `sha-<short>` tags when Docker Hub credentials are configured.
6. **Automated documentation sync:** Updates `versions.json`, the `<!-- versions:start -->` block in `README.md`, and `CHANGELOG.md` via `github-actions[bot]` (`[skip ci]`, checked by `public-check.sh`), then syncs README and short description to Docker Hub.
7. **Failure alerting:** Opens or updates a single GitHub issue labeled `ci-failure` on any `main` or scheduled failure, and auto-closes it on the next green run.

## Design Decisions

- **Runtime-download wrapper (zero proprietary redistribution):** Redistributing `plexmediaserver` binaries in a public third-party image violates Plex's Terms of Service. Keeping the published image strictly open-source Debian 13 + MIT wrapper scripts respects upstream licensing while providing a clean, patched Debian 13 runtime and automated daily smoke verification against live `plex.tv` releases.
- **`tini` + `setpriv` instead of S6 overlay v2:** Eliminates legacy S6 v2 binaries and stale Ubuntu 24.04 layers while staying compatible with `no-new-privileges:true` and clean `SIGTERM` propagation.

## License

- This repository and published wrapper image scripts: **MIT License** — see [LICENSE](LICENSE).
- Debian 13 (`trixie`) base packages: DFSG-compatible open-source licenses — see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
- Plex Media Server (downloaded directly by end users at container startup from `plex.tv`, **not** included in this image): proprietary software subject to the Plex Terms of Service.

## Credits

- [Debian Project](https://www.debian.org/)
- [Plex, Inc.](https://www.plex.tv/) (Plex Media Server, fetched directly by end users at runtime)

Maintained by **Daniel G. Cosenza from FNX Labs**.
