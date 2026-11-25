#!/usr/bin/env bash
# Healthcheck for dgcosenza/plex container
# Probes the local Plex Media Server /identity endpoint on TCP 32400.
set -euo pipefail

# -q must be the first argument so curl ignores any ~/.curlrc under HOME=/config
curl -q --connect-timeout 10 --max-time 30 --silent --show-error --fail \
    "http://127.0.0.1:32400/identity" >/dev/null
