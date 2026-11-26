# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Maintained by **Daniel G. Cosenza from FNX Labs**.

## [Unreleased]

<!-- changelog:auto -->

## [1.43.5.11079] — 2026-11-26

### Automated Daily Build
- Verified components: Wrapper Base OS `Debian 13.8 (trixie-slim)`, Smoke-Tested PMS Release (runtime-fetched) `1.43.5.11079-b3b13e506`, Proprietary Binaries in Published Image `None (0)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream changes:
  - **Latest tested public PMS release:** `1.43.5.11079-b3b13e506` -> `1.43.5.11079-b3b13e506`
  - **Upstream version changed:** `no`
  - Latest official public Plex Media Server Debian x86_64 release: `1.43.5.11079-b3b13e506` (SHA-1 `a0a0b8fa92aeea65128af07b7c6cffc994ab8795`). Note: binary is downloaded and verif...
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (23 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/plex@sha256:b91733ae5c74bfa894d6587bee3db1a0c70d86a670ced783085124b7a18a08c7` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [1.43.5.11079] — 2026-11-25

### Automated Daily Build
- Verified components: Wrapper Base OS `Debian 13.8 (trixie-slim)`, Smoke-Tested PMS Release (runtime-fetched) `1.43.5.11079-b3b13e506`, Proprietary Binaries in Published Image `None (0)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream changes:
  - **Latest tested public PMS release:** `1.43.5.11079-b3b13e506` -> `1.43.5.11079-b3b13e506`
  - **Upstream version changed:** `no`
  - Latest official public Plex Media Server Debian x86_64 release: `1.43.5.11079-b3b13e506` (SHA-1 `a0a0b8fa92aeea65128af07b7c6cffc994ab8795`). Note: binary is downloaded and verif...
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (23 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/plex@sha256:9579908c3aaddd0eb10c85276b9b924c7bc87caf19478b977662d0773268e82c` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

---

## [2026-11-24]

### Added
- Initial hardened Debian 13 (`trixie-slim`) runtime-installer wrapper for Plex Media Server containing zero proprietary Plex binaries.
- SHA-1 verified startup installer fetching the official Debian package directly from `downloads.plex.tv`, caching in `/config/.pms-deb-cache`, and launching `Plex Media Server` as non-root `plex` (`1000:1000`) under `tini`.
- Full `/healthcheck.sh` and `plexinc/pms-docker` mount/env parity, end-to-end live download smoke tests, multi-arch (`linux/amd64`, `linux/arm64`), Cosign OIDC signing, SPDX/CycloneDX SBOM attestations, SLSA Build L3 provenance, dual-registry publishing (GHCR + Docker Hub), and automated daily CI pipeline.

### Security
- Eliminated 3 fixable Ubuntu 24.04 vulnerabilities present in upstream `plexinc/pms-docker:latest`; verified 0 fixable Critical/High in Trivy and Grype.
