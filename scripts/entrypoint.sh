#!/usr/bin/env bash
set -euo pipefail

CONF_DIR="${CONF_DIR:-/azerothcore/env/dist/etc}"
LOGS_DIR="${LOGS_DIR:-/azerothcore/env/dist/logs}"

if ! touch "$CONF_DIR/.write-test" 2>/dev/null || ! touch "$LOGS_DIR/.write-test" 2>/dev/null; then
  echo "WARNING: Current user ($(id -u):$(id -g)) cannot write to ${CONF_DIR} or ${LOGS_DIR}." >&2
fi
rm -f "$CONF_DIR/.write-test" "$LOGS_DIR/.write-test" 2>/dev/null || true

# Seed default .conf.dist files into CONF_DIR without clobbering existing custom configs
if [ -d /azerothcore/env/ref/etc ]; then
  cp -rn /azerothcore/env/ref/etc/. "$CONF_DIR/" 2>/dev/null || true
fi

CONF="${CONF_DIR}/${ACORE_COMPONENT}.conf"
CONF_DIST="${CONF_DIR}/${ACORE_COMPONENT}.conf.dist"

if [ ! -f "$CONF" ]; then
  if [ -f "$CONF_DIST" ]; then
    cp -n "$CONF_DIST" "$CONF"
  else
    touch "$CONF"
  fi
fi

echo "Starting ${ACORE_COMPONENT}..."
exec "$@"
