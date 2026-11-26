#!/usr/bin/env bash
# CI-only healthcheck validation for the three published targets.
#
# Each target's Dockerfile HEALTHCHECK is exercised exactly as written: a TCP
# probe on 3724 (authserver) / 8085 (worldserver), and `pgrep -x dbimport` on
# the one-shot db-import target. The CI runner has no game database, so a tiny
# static stub satisfies each probe condition while Docker verifies the real
# HEALTHCHECK instruction and reports status=healthy. Service binaries,
# non-root UID/GID, tini PID 1 and library resolution are covered by smoke.sh.
set -euo pipefail

ARCH="${1:?usage: health-wait.sh <arch> <image-prefix>}"
PREFIX="${2:-dgcosenza/ac-wotlk}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

cc -static -O2 -Wall -Wextra -o "${WORKDIR}/health-stub" tests/health-stub.c
# pgrep -x matches the process name (comm), so the idle stub needs this filename.
cp "${WORKDIR}/health-stub" "${WORKDIR}/dbimport"

wait_healthy() {
  local component="$1" entrypoint="$2" probe_arg="${3:-}"
  local image="${PREFIX}-${component}:ci-candidate-${ARCH}"
  local cid status=""
  echo "=== Waiting for ${component} (${ARCH}) to become healthy ==="
  cid="$(docker run -d --security-opt no-new-privileges:true \
      -v "${WORKDIR}/health-stub:/health-stub:ro" \
      -v "${WORKDIR}/dbimport:/dbimport:ro" \
      --entrypoint "${entrypoint}" "${image}" ${probe_arg})"
  for _ in $(seq 1 60); do
    status="$(docker inspect --format='{{.State.Health.Status}}' "$cid" 2>/dev/null || echo starting)"
    if [ "$status" = "healthy" ]; then
      echo "${component} is healthy"
      docker kill "$cid" >/dev/null 2>&1 || true
      docker rm "$cid" >/dev/null 2>&1 || true
      return 0
    fi
    if [ "$status" = "unhealthy" ]; then
      echo "${component} became unhealthy" >&2
      docker logs "$cid" || true
      docker rm -f "$cid" >/dev/null 2>&1 || true
      return 1
    fi
    sleep 2
  done
  echo "${component} did not become healthy in time (last=${status})" >&2
  docker logs "$cid" || true
  docker rm -f "$cid" >/dev/null 2>&1 || true
  return 1
}

wait_healthy authserver /health-stub 3724
wait_healthy worldserver /health-stub 8085
wait_healthy db-import /dbimport

echo "All three targets reached Docker status=healthy (${ARCH})."
