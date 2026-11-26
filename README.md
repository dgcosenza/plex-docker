# Plex Media Server Runtime Wrapper on Debian 13 (trixie)

[![Daily Plex wrapper image](https://github.com/dgcosenza/plex-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/plex-docker/actions/workflows/daily.yml)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue.svg)](https://github.com/dgcosenza/plex-docker/blob/main/LICENSE)
[![Upstream License: Proprietary (runtime-fetched)](https://img.shields.io/badge/upstream-Proprietary--ToS-orange.svg)](https://www.plex.tv/about/privacy-legal/plex-terms-of-service/)
[![Signed with Cosign](https://img.shields.io/badge/signed-cosign%20OIDC-blueviolet.svg)](#supply-chain-verification)
[![SLSA Level 3](https://img.shields.io/badge/SLSA-Level%203-brightgreen.svg)](#supply-chain-verification)
[![Architectures](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-informational.svg)](#supported-architectures)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/plex-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/plex-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/plex)](https://hub.docker.com/r/dgcosenza/plex)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/plex/latest)](https://hub.docker.com/r/dgcosenza/plex)
[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/plex-docker?label=version)](https://github.com/dgcosenza/plex-docker/releases)

A hardened, multi-arch **Debian 13 (`trixie-slim`) runtime-installer wrapper** for **Plex Media Server** with `tini` PID 1, SHA-1 verified startup package retrieval directly from `plex.tv`, non-root daemon execution (`plex`, UID/GID `1000:1000`), and drop-in compatibility with `plexinc/pms-docker`, maintained by **Daniel G. Cosenza from FNX Labs**.

- **Docker Hub:** [`dgcosenza/plex`](https://hub.docker.com/r/dgcosenza/plex)
- **GitHub Container Registry (GHCR):** [`ghcr.io/dgcosenza/plex`](https://github.com/dgcosenza/plex-docker/pkgs/container/plex) (identical signed multi-arch digest)
- **Source Repository:** [`dgcosenza/plex-docker`](https://github.com/dgcosenza/plex-docker)
- **Upstream Application:** [Plex Media Server](https://www.plex.tv/) (`Proprietary` — fetched directly by end users at runtime, **not** bundled)

> **Licensing & Redistribution Notice:** Plex Media Server is proprietary software governed by the [Plex Terms of Service](https://www.plex.tv/about/privacy-legal/plex-terms-of-service/), which prohibits third-party redistribution of Plex binaries. **This image contains zero proprietary Plex binaries.** At container startup, `/init` fetches the official Debian package directly from `downloads.plex.tv`, verifies its SHA-1 checksum against the official `plex.tv` manifest, caches it in `/config/.pms-deb-cache`, installs it locally in the running container, and launches Plex Media Server as the non-root `plex` user.

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| Wrapper Base OS | `Debian 13.8 (trixie-slim)` |
| Smoke-Tested PMS Release (runtime-fetched) | `1.43.5.11079-b3b13e506` |
| Proprietary Binaries in Published Image | `None (0)` |
| Architectures | `linux/amd64, linux/arm64` |
| Uncompressed size (per arch) | `amd64: 45.6 MB, arm64: 147.3 MB` |
| Last verified build (UTC) | `2026-11-26` |
| Published multi-arch digest | `dgcosenza/plex@sha256:7d7bc0a56242a50accc787b311ad062822b7edc086edbfb0961a5266816f5cee` |
| GHCR mirror | `ghcr.io/dgcosenza/plex@sha256:7d7bc0a56242a50accc787b311ad062822b7edc086edbfb0961a5266816f5cee` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable findings of any severity** (23 upstream-unfixed) |

**Recent upstream changes:**
- **Latest tested public PMS release:** `1.43.5.11079-b3b13e506` -> `1.43.5.11079-b3b13e506`
- **Upstream version changed:** `no`
- Latest official public Plex Media Server Debian x86_64 release: `1.43.5.11079-b3b13e506` (SHA-1 `a0a0b8fa92aeea65128af07b7c6cffc994ab8795`). Note: binary is downloaded and verif...
<!-- versions:end -->

---

## Supported Tags & Tag Policy

Identical multi-arch OCI digests are published to **Docker Hub** (`dgcosenza/plex`) and **GHCR** (`ghcr.io/dgcosenza/plex`), accompanied by an automated signed [GitHub Release](https://github.com/dgcosenza/plex-docker/releases):

| Tag | Policy | Description |
| --- | --- | --- |
| `<pms-version>-<YYYYMMDD>` (e.g. `1.43.5.11079-20261125`) | **Immutable** | Date-stamped daily wrapper build tested against the listed public PMS release. |
| `sha-<short>` | **Immutable** | Packaging repository Git commit tag. |
| `<pms-version>` (e.g. `1.43.5.11079`) | Moving | Latest verified wrapper build tested against that public PMS release. |
| `latest` | Moving | Latest verified daily Debian 13 runtime wrapper build. |

**Production pinning:** Pin by immutable registry digest rather than an unpinned moving tag:

```yaml
image: dgcosenza/plex:latest@sha256:<digest>
# or via GitHub Container Registry (identical digest):
image: ghcr.io/dgcosenza/plex:latest@sha256:<digest>
```

---

## Supported Architectures

| Architecture | Status | Verification |
| --- | --- | --- |
| `linux/amd64` | **Published & natively tested** | Built, verified zero proprietary binaries, end-to-end smoke-tested with live `amd64` `.deb` download/SHA-1 verify + `/identity` HTTP 200, Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native x86_64 CI runners. |
| `linux/arm64` | **Published & natively tested** | Built, verified zero proprietary binaries, end-to-end smoke-tested with live `arm64` `.deb` download/SHA-1 verify + `/identity` HTTP 200, Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native ARM64 CI runners. |

---

## Quick Start

### Docker CLI

```bash
docker run -d --name plex \
  --cap-drop ALL \
  --cap-add SETUID \
  --cap-add SETGID \
  --cap-add CHOWN \
  --cap-add FOWNER \
  --cap-add DAC_OVERRIDE \
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

### Hardened Docker Compose

See [`docker-compose.example.yml`](https://github.com/dgcosenza/plex-docker/blob/main/docker-compose.example.yml):

```yaml
services:
  plex:
    image: dgcosenza/plex:latest
    restart: unless-stopped
    cap_drop:
      - ALL
    cap_add:
      - SETUID
      - SETGID
      - CHOWN
      - FOWNER
      - DAC_OVERRIDE
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

---

## Configuration

### Environment Variables

| Variable | Description | Default |
| --- | --- | --- |
| `VERSION` | `public` (latest public release), `plexpass` / `beta` (requires `PLEX_TOKEN`), or `docker` (skip download if already installed) | `public` |
| `PLEX_UID` / `PLEX_GID` | UID/GID used to run Plex Media Server and own `/config` | `1000` / `1000` |
| `CHANGE_CONFIG_DIR_OWNERSHIP` | Set to `false` to skip `chown` on `/config` and `/transcode` | `true` |
| `PLEX_TOKEN` | Optional Plex Pass token for `plexpass` channel lookups | — |
| `ADVERTISE_IP` | Custom server connection URLs written to `Preferences.xml` | — |
| `ALLOWED_NETWORKS` | Networks allowed without auth in `Preferences.xml` | — |
| `TZ` | Container timezone | `UTC` |

### Volumes, Ports, and Privileges

| Path / Port | Purpose |
| --- | --- |
| `/config` | Plex configuration root (also caches the verified `.deb` under `/config/.pms-deb-cache`) |
| `/config/Library/Application Support/Plex Media Server` | Existing PMS database, metadata, and `Preferences.xml` |
| `/transcode` | Temporary transcode scratch directory |
| `/media` | Media libraries (mount `:ro` where possible) |
| `32400/tcp` | Primary Plex Media Server HTTP/HTTPS port |
| `8324/tcp`, `32469/tcp`, `1900/udp`, `32410-32414/udp` | Optional discovery / DLNA / GDM ports |

`/init` runs briefly as `root` solely to install the SHA-1 verified Debian `.deb` into `/usr/lib/plexmediaserver` and apply optional ownership adjustments, then drops privileges via `setpriv` to non-root **`plex` (UID/GID `1000:1000`)** before `exec`ing `Plex Media Server`.

---

## Healthcheck

```bash
/healthcheck.sh
```

Probes `http://127.0.0.1:32400/identity` via `curl -q` (ignoring any user `~/.curlrc` inside `/config`).

---

## Upgrade and Migration from `plexinc/pms-docker`

1. Back up your Plex database directory (`/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases`) before switching.
2. Keep all existing volume mounts (`/config/Library/Application Support/Plex Media Server`, `/tmp`, `/media/*`), `network_mode: host`, and `/healthcheck.sh` unchanged.
3. Ensure your container has outbound HTTPS access to `plex.tv` and `downloads.plex.tv` on startup so the official Debian `.deb` can be downloaded and SHA-1 verified.
4. Tag the outgoing image locally for rollback, switch `image:` to `dgcosenza/plex:latest@sha256:<digest>` (or GHCR), and run `docker compose up -d plex`.

---

## Supply-Chain Verification

Every published digest (multi-arch index and per-architecture manifests) on both Docker Hub and GHCR is keyless-signed with **Sigstore Cosign** (GitHub OIDC), attested with **SPDX** and **CycloneDX** SBOMs, and backed by **SLSA Build L3** provenance (`actions/attest-build-provenance`).

### Verify image signature with Cosign

```bash
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/plex-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/plex:latest

# Or against Docker Hub (identical digest):
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/plex-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  dgcosenza/plex:latest
```

### Verify SPDX / CycloneDX SBOM attestations

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/plex-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/plex@sha256:<arch-digest>
```

### Verify SLSA Build Provenance

```bash
gh attestation verify oci://ghcr.io/dgcosenza/plex:latest --owner dgcosenza
```

---

## Security

- **Preflight gates:** Every push and PR runs **Hadolint** (blocking on warning+), **Gitleaks** secret scanning across git history, and **public-content/attribution** checks.
- **Vulnerability scan policy (all severities with a fix):** Every build generates **SPDX** and **CycloneDX** SBOMs with **Syft** per architecture, scans with **Trivy** (table, JSON, SARIF upload, blocking `--ignore-unfixed` gate) and **Grype** scanning the SPDX SBOM (`--only-fixed --fail-on negligible`), and enforces a **Dive** efficiency gate (`>= 95%`).
- **Runtime integrity:** `.deb` downloads are strictly verified against the official SHA-1 checksum published in `https://plex.tv/api/downloads/5.json` before `dpkg -i`.
- **Non-root daemon:** `Plex Media Server` runs as unprivileged `plex` (`1000:1000`), compatible with `no-new-privileges:true`.
- **Dependency automation:** Renovate (`renovate.json`) pins base image digests and GitHub Action commit SHAs; Dependabot security alerts and OpenSSF Scorecard monitoring are enabled.
- See [`SECURITY.md`](https://github.com/dgcosenza/plex-docker/blob/main/SECURITY.md) for responsible disclosure.

---

## Build Locally

```bash
docker buildx build --platform linux/amd64 --load -t dgcosenza/plex:local .
```

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/plex-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **05:47 UTC**, on pushes to `main`, on pull requests (verification only), and via `workflow_dispatch`:

1. **Preflight & upstream check:** Runs public-content checks, **Hadolint**, and **Gitleaks**; queries `https://plex.tv/api/downloads/5.json` for the latest public Debian PMS metadata and resolves the latest `debian:trixie-slim` digest, emitting `upstream-changes.md`.
2. **Multi-arch no-cache rebuild:** Rebuilds the minimal `debian:trixie-slim` wrapper natively on `linux/amd64` and `linux/arm64` runners with `--no-cache` on schedule and `apt-get upgrade`.
3. **Smoke, Dive & vulnerability gates:** Runs [`tests/smoke.sh`](https://github.com/dgcosenza/plex-docker/blob/main/tests/smoke.sh) natively on both architectures (verifying zero baked binaries, live SHA-1 verified `.deb` install, UID `1000` startup, `/identity` HTTP 200 XML, and negative healthcheck), enforces the **Dive** efficiency gate (`>= 95%`), generates **Syft** SPDX + CycloneDX SBOMs per arch, and gates publication on **0 fixable findings of any severity** in both **Trivy** and **Grype** (scanning the SPDX SBOM).
4. **Dual-registry publish & supply-chain signing:** Assembles the multi-arch OCI manifest index on **GHCR** (`ghcr.io/dgcosenza/plex`) and mirrors the identical digest to **Docker Hub** (`dgcosenza/plex`) with tags `latest`, `<version>`, `<version>-<YYYYMMDD>`, and `sha-<short>`; signs every digest and attaches SPDX/CycloneDX SBOM attestations via **Cosign** keyless OIDC; emits **SLSA Build L3** provenance; and publishes a signed **GitHub Release** with checksums and SBOMs.
5. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry via `github-actions[bot]` (`[skip ci]`, validated by `public-check.sh`), then syncs the Docker Hub overview and short description.
6. **Failure alerting:** Opens or updates a single GitHub issue labeled `ci-failure` on any `main` or scheduled failure, and auto-closes it on the next green run.

---

## Design Decisions

- **Runtime-download wrapper (zero proprietary redistribution):** Redistributing `plexmediaserver` binaries in a public third-party image violates Plex's Terms of Service. Keeping the published image strictly open-source Debian 13 + MIT wrapper scripts respects upstream licensing while providing a patched Debian 13 runtime and daily smoke verification against live `plex.tv` releases.
- **`tini` + `setpriv` instead of S6 overlay v2:** Eliminates legacy S6 v2 binaries and stale Ubuntu 24.04 layers while staying compatible with `no-new-privileges:true` and clean `SIGTERM` propagation.
- **Hadolint `DL3008` ignore:** Daily `--no-cache` security rebuilds intentionally pull the newest Debian 13 security updates via `apt-get`.
- **Dive `highestUserWastedPercent: 0.25`:** Overall image efficiency remains strictly gated at `>= 95%`. Because the wrapper installs only tiny runtime utilities (~25 MB delta), daily `apt-get -y upgrade` overwrites (~5 MB of base layer files) represent ~20% of user bytes while keeping total image efficiency >95%.

---

## License

This repository follows a clear packaging-vs-upstream license split:

- **Container packaging, runtime wrapper scripts, CI workflows, and documentation (`packaging: MIT`):** Licensed under the [MIT License](https://github.com/dgcosenza/plex-docker/blob/main/LICENSE) — copyright **Daniel G. Cosenza from FNX Labs**.
- **Runtime-fetched upstream software — Plex Media Server (`upstream: Proprietary-ToS`):** Proprietary software governed by the [Plex Terms of Service](https://www.plex.tv/about/privacy-legal/plex-terms-of-service/). **No Plex binaries are included or redistributed in this image**; end users fetch the official package directly from `plex.tv` at container startup.

Full third-party notices for Debian 13 open-source packages are maintained in [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/plex-docker/blob/main/THIRD-PARTY-NOTICES.md). Release history is maintained in [`CHANGELOG.md`](https://github.com/dgcosenza/plex-docker/blob/main/CHANGELOG.md).

## Credits

- [Debian Project](https://www.debian.org/)
- [Plex, Inc.](https://www.plex.tv/) (Plex Media Server, fetched directly by end users at runtime)

Maintained by **Daniel G. Cosenza from FNX Labs**.
