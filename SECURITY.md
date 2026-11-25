# Security Policy

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Supported Versions

Only the latest daily build (`latest`) receives security updates. Immutable date-stamped tags (`<version>-YYYYMMDD`) are frozen for reproducibility.

## Vulnerability Scanning & Gates

- **Trivy** (OS + packages): SARIF uploaded to GitHub Code Scanning; table and JSON reports retained for 90 days; **blocking hard gate** on any fixable `CRITICAL` or `HIGH` finding.
- **Grype**: **blocking hard gate** (`only-fixed: true`, severity cutoff `high`); table report retained for 90 days.
- **SBOM & Provenance**: SPDX-JSON SBOM via Syft plus provenance JSON retained for 90 days.
- **Download Verification**: Runtime Plex Media Server `.deb` downloads are verified against the official SHA-1 checksum published by `plex.tv` before installation.

## Reporting a Vulnerability

**Do not open a public issue** for security vulnerabilities.

Report privately through GitHub Security Advisories: open the repository's **Security** tab or submit a private advisory directly at [dgcosenza/plex-docker Security Advisories](https://github.com/dgcosenza/plex-docker/security/advisories/new).

For upstream Plex Media Server vulnerabilities, follow the [Plex Security Policy](https://www.plex.tv/security/).
