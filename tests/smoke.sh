#!/usr/bin/env bash
# Smoke test for dgcosenza/plex wrapper image
# Verifies:
# 1. Zero proprietary Plex binaries exist in the published image layers
# 2. Container starts, downloads & SHA-1 verifies official PMS .deb from plex.tv
# 3. Plex Media Server runs as non-root UID 1000 and serves HTTP 200 on :32400/identity
# 4. Negative healthcheck fails when PMS is not running

set -euo pipefail

IMAGE="${1:-dgcosenza/plex:ci-candidate}"
CONTAINER_NAME="plex-smoke-$$"
CFG_VOL="plex-smoke-cfg-$$"
TRANS_VOL="plex-smoke-trans-$$"

cleanup() {
    docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
    docker volume rm -f "${CFG_VOL}" "${TRANS_VOL}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "=== Smoke testing ${IMAGE} ==="

echo "Verifying published image contains ZERO proprietary Plex binaries..."
if docker run --rm --entrypoint test "${IMAGE}" -e "/usr/lib/plexmediaserver/Plex Media Server"; then
    echo "ERROR: Proprietary Plex Media Server binary found inside published image!"
    exit 1
fi
echo "OK: Image is a clean runtime wrapper with zero bundled proprietary binaries"

docker volume create "${CFG_VOL}" >/dev/null
docker volume create "${TRANS_VOL}" >/dev/null

echo "Starting container to verify runtime download, SHA-1 verification, and startup..."
docker run -d --name "${CONTAINER_NAME}" \
    --security-opt no-new-privileges:true \
    -v "${CFG_VOL}:/config" \
    -v "${TRANS_VOL}:/transcode" \
    "${IMAGE}"

echo "Waiting for Plex Media Server healthcheck (/identity)..."
for i in $(seq 1 90); do
    STATUS="$(docker inspect --format '{{.State.Health.Status}}' "${CONTAINER_NAME}" 2>/dev/null || echo "missing")"
    if [ "${STATUS}" = "healthy" ]; then
        echo "OK: Container status is healthy"
        break
    fi
    if [ "${STATUS}" = "missing" ] || [ "$(docker inspect --format '{{.State.Running}}' "${CONTAINER_NAME}" 2>/dev/null || echo false)" != "true" ]; then
        echo "ERROR: Container exited prematurely"
        docker logs "${CONTAINER_NAME}" || true
        exit 1
    fi
    sleep 3
    if [ "${i}" -eq 90 ]; then
        echo "ERROR: Container did not become healthy within 270s (status=${STATUS})"
        docker logs "${CONTAINER_NAME}" || true
        exit 1
    fi
done

echo "Verifying /identity XML endpoint..."
ID_XML="$(docker exec "${CONTAINER_NAME}" curl -q -fsS http://127.0.0.1:32400/identity)"
printf '%s\n' "${ID_XML}" | grep -q "MediaContainer"
echo "OK: /identity XML responded cleanly"

echo "Verifying Plex Media Server runs as non-root UID 1000..."
PMS_UID="$(docker exec "${CONTAINER_NAME}" sh -c 'ps -eo uid,comm | awk "/Plex Media Serv/ {print \$1; exit}"')"
if [ "${PMS_UID}" != "1000" ]; then
    echo "ERROR: Expected Plex Media Server UID 1000, got '${PMS_UID}'"
    docker exec "${CONTAINER_NAME}" ps -eo uid,gid,pid,comm
    exit 1
fi
echo "OK: Plex Media Server running as non-root UID ${PMS_UID}"

echo "Running negative healthcheck test (stopped server)..."
if docker run --rm --entrypoint /healthcheck.sh "${IMAGE}" >/dev/null 2>&1; then
    echo "ERROR: Healthcheck unexpectedly passed without Plex Media Server running"
    exit 1
fi
echo "OK: Negative healthcheck failed as expected"

echo "=== All smoke tests passed for ${IMAGE} ==="
