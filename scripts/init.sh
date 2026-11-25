#!/usr/bin/env bash
# Runtime installer and launcher for Plex Media Server on Debian 13 (trixie).
# Downloads and SHA-1 verifies the official Debian package from plex.tv at container
# start so zero proprietary Plex binaries are redistributed in the container image.

set -euo pipefail

log() {
    printf '%s [plex-init] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"
}

PLEX_UID="${PLEX_UID:-1000}"
PLEX_GID="${PLEX_GID:-1000}"
VERSION_REQ="${VERSION:-public}"
ARCH="$(dpkg --print-architecture)"

case "${ARCH}" in
    amd64) PLEX_BUILD="linux-x86_64" ;;
    arm64) PLEX_BUILD="linux-aarch64" ;;
    *)
        log "ERROR: Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

# Adjust plex UID/GID if overridden by environment
if [ "$(id -g plex)" != "${PLEX_GID}" ]; then
    groupmod --non-unique --gid "${PLEX_GID}" plex
fi
if [ "$(id -u plex)" != "${PLEX_UID}" ]; then
    usermod --non-unique --uid "${PLEX_UID}" --gid "${PLEX_GID}" plex
fi

# Resolve official download manifest from plex.tv
resolve_and_install_pms() {
    local manifest_url="https://plex.tv/api/downloads/5.json"
    local installed_ver=""
    if dpkg-query -W -f='${Status}' plexmediaserver 2>/dev/null | grep -q "install ok installed"; then
        installed_ver="$(dpkg-query -W -f='${Version}' plexmediaserver || true)"
    fi

    if [ "${VERSION_REQ}" = "docker" ] && [ -x "/usr/lib/plexmediaserver/Plex Media Server" ]; then
        log "VERSION=docker and Plex Media Server ${installed_ver} is already installed."
        return 0
    fi

    if [ "${VERSION_REQ}" = "plexpass" ] || [ "${VERSION_REQ}" = "beta" ]; then
        if [ -n "${PLEX_TOKEN:-}" ]; then
            manifest_url="https://plex.tv/api/downloads/5.json?channel=plexpass"
        fi
    fi

    log "Querying official Plex download manifest (${PLEX_BUILD}, distro=debian)..."
    local curl_args=(-q -fsSL --connect-timeout 15 --max-time 60)
    if [ -n "${PLEX_TOKEN:-}" ]; then
        curl_args+=(-H "X-Plex-Token: ${PLEX_TOKEN}")
    fi

    local manifest
    manifest="$(curl "${curl_args[@]}" "${manifest_url}")"

    local remote_ver remote_url remote_sha1
    remote_ver="$(printf '%s' "${manifest}" | jq -r '.computer.Linux.version // empty')"
    remote_url="$(printf '%s' "${manifest}" | jq -r --arg b "${PLEX_BUILD}" '.computer.Linux.releases[] | select(.distro=="debian" and .build==$b) | .url' | head -n 1)"
    remote_sha1="$(printf '%s' "${manifest}" | jq -r --arg b "${PLEX_BUILD}" '.computer.Linux.releases[] | select(.distro=="debian" and .build==$b) | .checksum' | head -n 1)"

    if [ -z "${remote_ver}" ] || [ -z "${remote_url}" ] || [ -z "${remote_sha1}" ]; then
        log "ERROR: Failed to parse Plex download metadata for ${PLEX_BUILD}"
        exit 1
    fi

    if [ "${installed_ver}" = "${remote_ver}" ] && [ -x "/usr/lib/plexmediaserver/Plex Media Server" ]; then
        log "Plex Media Server ${installed_ver} is already up to date."
        return 0
    fi

    local cache_dir="/config/.pms-deb-cache"
    mkdir -p "${cache_dir}"
    local deb_file="${cache_dir}/plexmediaserver_${remote_ver}_${ARCH}.deb"

    if [ -f "${deb_file}" ] && printf '%s  %s\n' "${remote_sha1}" "${deb_file}" | sha1sum -c - >/dev/null 2>&1; then
        log "Using verified cached package: ${deb_file}"
    else
        log "Downloading Plex Media Server ${remote_ver} from downloads.plex.tv..."
        curl -q -fsSL --retry 3 --retry-delay 3 --connect-timeout 15 --max-time 300 -o "${deb_file}.tmp" "${remote_url}"
        if ! printf '%s  %s\n' "${remote_sha1}" "${deb_file}.tmp" | sha1sum -c -; then
            rm -f "${deb_file}.tmp"
            log "ERROR: SHA-1 checksum mismatch for downloaded Plex Media Server package!"
            exit 1
        fi
        mv -f "${deb_file}.tmp" "${deb_file}"
        # Keep only the newest cached deb to avoid disk growth
        find "${cache_dir}" -maxdepth 1 -type f -name 'plexmediaserver_*.deb' ! -path "${deb_file}" -delete || true
    fi

    log "Installing Plex Media Server ${remote_ver}..."
    DEBIAN_FRONTEND=noninteractive dpkg --force-confold -i "${deb_file}"
    log "Installed Plex Media Server ${remote_ver}."
}

resolve_and_install_pms

# Prepare Plex application support and transcode directories
APP_SUPPORT="${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR:-/config/Library/Application Support}"
PMS_DATA_DIR="${APP_SUPPORT}/Plex Media Server"
mkdir -p "${PMS_DATA_DIR}" /transcode

# Clean stale PID file if left over from an unclean host shutdown
rm -f "${PMS_DATA_DIR}/plexmediaserver.pid"

# Ensure Preferences.xml exists and apply optional claim/advertise settings
PREFS_FILE="${PMS_DATA_DIR}/Preferences.xml"
if [ ! -f "${PREFS_FILE}" ]; then
    MACHINE_ID="$(uuidgen)"
    cat > "${PREFS_FILE}" <<XML
<?xml version="1.0" encoding="utf-8"?>
<Preferences MachineIdentifier="${MACHINE_ID}" ProcessedMachineIdentifier="${MACHINE_ID}" AnonymousMachineIdentifier="${MACHINE_ID}" AcceptedEULA="1"/>
XML
fi

if [ -n "${ADVERTISE_IP:-}" ]; then
    xmlstarlet ed -L -u '/Preferences/@customConnections' -v "${ADVERTISE_IP}" "${PREFS_FILE}" 2>/dev/null \
        || xmlstarlet ed -L -i '/Preferences' -t attr -n customConnections -v "${ADVERTISE_IP}" "${PREFS_FILE}"
fi

if [ -n "${ALLOWED_NETWORKS:-}" ]; then
    xmlstarlet ed -L -u '/Preferences/@allowedNetworks' -v "${ALLOWED_NETWORKS}" "${PREFS_FILE}" 2>/dev/null \
        || xmlstarlet ed -L -i '/Preferences' -t attr -n allowedNetworks -v "${ALLOWED_NETWORKS}" "${PREFS_FILE}"
fi

if [ "${CHANGE_CONFIG_DIR_OWNERSHIP:-true}" = "true" ]; then
    chown "${PLEX_UID}:${PLEX_GID}" /config /transcode "${APP_SUPPORT}" "${PMS_DATA_DIR}" "${PREFS_FILE}" 2>/dev/null || true
    chown -R "${PLEX_UID}:${PLEX_GID}" /config/.pms-deb-cache 2>/dev/null || true
fi

# Scrub sensitive claim/token env vars from runtime if already processed
unset PLEX_CLAIM || true

export PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver"
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="${APP_SUPPORT}"
export PLEX_MEDIA_SERVER_TMPDIR="${PLEX_MEDIA_SERVER_TMPDIR:-/tmp}"
export LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}/lib:${LD_LIBRARY_PATH:-}"
export HOME="/config"

log "Starting Plex Media Server as user plex (${PLEX_UID}:${PLEX_GID})..."
exec setpriv --reuid="${PLEX_UID}" --regid="${PLEX_GID}" --init-groups -- \
    "${PLEX_MEDIA_SERVER_HOME}/Plex Media Server"
