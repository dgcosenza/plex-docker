# syntax=docker/dockerfile:1.7
# Hardened Plex Media Server Runtime-Installer Wrapper on Debian 13 (trixie)
# IMPORTANT: Contains ZERO proprietary Plex binaries. The official Plex Media Server
# Debian package is downloaded directly from plex.tv and SHA-1 verified at container start.
# Maintainer: Daniel G. Cosenza from FNX Labs

ARG DEBIAN_BASE=debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0
ARG PLEX_VERSION=1.43.5.11079-b3b13e506
ARG IMAGE_CREATED=1970-01-01T00:00:00Z
ARG IMAGE_REVISION=dev
ARG IMAGE_SOURCE=https://github.com/dgcosenza/plex-docker

FROM ${DEBIAN_BASE} AS runtime

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG PLEX_VERSION
ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_SOURCE
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.title="Plex Media Server Runtime Wrapper on Debian 13 (trixie)" \
      org.opencontainers.image.description="Hardened Debian 13 (trixie-slim) runtime-installer wrapper for Plex Media Server. Contains no proprietary Plex binaries; downloads and verifies the official package from plex.tv on startup. Maintained by Daniel G. Cosenza from FNX Labs." \
      org.opencontainers.image.version="${PLEX_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/plex" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.base.name="debian:trixie-slim" \
      io.github.dgcosenza.plex.mode="runtime-download-wrapper" \
      io.github.dgcosenza.plex.tested_version="${PLEX_VERSION}"

RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        procps \
        tini \
        tzdata \
        util-linux \
        uuid-runtime \
        xmlstarlet; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    \
    groupadd --gid 1000 plex; \
    useradd --uid 1000 --gid 1000 --home-dir /config --shell /usr/sbin/nologin --groups users plex; \
    mkdir -p /config /transcode /data /media /tmp; \
    chown -R 1000:1000 /config /transcode /data

COPY --chmod=0755 scripts/init.sh /init
COPY --chmod=0755 scripts/healthcheck.sh /healthcheck.sh

ENV TERM="xterm" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    TZ="UTC" \
    HOME="/config" \
    PLEX_UID="1000" \
    PLEX_GID="1000" \
    CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    VERSION="public" \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    PLEX_MEDIA_SERVER_INFO_VENDOR="Docker" \
    PLEX_MEDIA_SERVER_INFO_DEVICE="Docker Container"

EXPOSE 32400/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp

VOLUME ["/config", "/transcode"]

ENTRYPOINT ["/usr/bin/tini", "--", "/init"]
CMD []

HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=5 \
    CMD ["/healthcheck.sh"]
