# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Maintained by **Daniel G. Cosenza from FNX Labs**.

## [Unreleased]

<!-- changelog:auto -->

---

## [2026-11-24]

### Added
- Initial hardened Debian 13 (`trixie-slim`) runtime-installer wrapper for Plex Media Server containing zero proprietary Plex binaries.
- SHA-1 verified startup installer fetching the official Debian package directly from `downloads.plex.tv`, caching in `/config/.pms-deb-cache`, and launching `Plex Media Server` as non-root `plex` (`1000:1000`) under `tini`.
- Full `/healthcheck.sh` and `plexinc/pms-docker` mount/env parity, end-to-end live download smoke tests, multi-arch (`linux/amd64`, `linux/arm64`), Cosign OIDC signing, SPDX/CycloneDX SBOM attestations, SLSA Build L3 provenance, dual-registry publishing (GHCR + Docker Hub), and automated daily CI pipeline.

### Security
- Eliminated 3 fixable Ubuntu 24.04 vulnerabilities present in upstream `plexinc/pms-docker:latest`; verified 0 fixable Critical/High in Trivy and Grype.
