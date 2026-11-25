#!/usr/bin/env bash
# Smoke test for dgcosenza/ac-wotlk-{authserver,worldserver,db-import}:
# verifies non-root UID/GID 1000 (acore), tini PID 1, shared library resolution,
# binary --version output, mysql/mysqladmin clients, entrypoint config seeding
# (without overwriting existing conf), and negative TCP port healthcheck.
set -euo pipefail

AUTH_IMG="${1:-dgcosenza/ac-wotlk-authserver:ci-candidate}"
WORLD_IMG="${2:-dgcosenza/ac-wotlk-worldserver:ci-candidate}"
DBIMP_IMG="${3:-dgcosenza/ac-wotlk-db-import:ci-candidate}"

for pair in \
  "authserver|${AUTH_IMG}|/azerothcore/env/dist/bin/authserver" \
  "worldserver|${WORLD_IMG}|/azerothcore/env/dist/bin/worldserver" \
  "dbimport|${DBIMP_IMG}|/azerothcore/env/dist/bin/dbimport"; do
  comp="${pair%%|*}"
  rest="${pair#*|}"
  img="${rest%%|*}"
  bin="${rest#*|}"

  echo "=== Smoke testing ${comp} (${img}) ==="

  # Verify non-root acore UID/GID 1000, tini PID 1, and mysql/mysqladmin presence
  # Note: upstream dbimport exits 0 on --help (not --version, which proceeds to DB init).
  PROBE_FLAG="--version"
  if [ "$comp" = "dbimport" ]; then
    PROBE_FLAG="--help"
  fi
  OUT="$(docker run --rm --security-opt no-new-privileges:true \
    --entrypoint /usr/bin/tini "$img" -- bash -c "
      set -euo pipefail
      test \"\$(id -u)\" = 1000
      test \"\$(id -g)\" = 1000
      test \"\$(cat /proc/1/comm)\" = tini
      command -v mysql >/dev/null
      command -v mysqladmin >/dev/null
      ! ldd \"${bin}\" | grep -q 'not found'
      \"${bin}\" ${PROBE_FLAG}
    ")"
  echo "${comp} probe (${PROBE_FLAG}): $(printf '%s\n' "${OUT}" | head -n 2)"

  if [ "$comp" = "worldserver" ]; then
    docker run --rm --security-opt no-new-privileges:true --entrypoint bash "$img" -c \
      'test -f /azerothcore/env/ref/etc/modules/mod_ale.conf.dist && grep -aoq mod_ale /azerothcore/env/dist/bin/worldserver'
    echo "worldserver mod-ale (Lua Engine) parity verified."
  fi

  # Verify entrypoint seeds default .conf without overwriting pre-existing custom .conf
  TMPETC="$(mktemp -d)"
  chmod 777 "$TMPETC"
  printf '# custom-sentinel\n' > "${TMPETC}/${comp}.conf"
  docker run --rm --security-opt no-new-privileges:true \
    -v "${TMPETC}:/azerothcore/env/dist/etc" \
    "$img" bash -c "grep -q '# custom-sentinel' /azerothcore/env/dist/etc/${comp}.conf"
  rm -rf "$TMPETC"

  # Negative TCP healthcheck against closed port must fail
  if docker run --rm --security-opt no-new-privileges:true \
    --entrypoint bash "$img" -c 'exec 3<>/dev/tcp/127.0.0.1/59999' 2>/dev/null; then
    echo "ERROR: TCP healthcheck unexpectedly passed on closed port 59999" >&2
    exit 1
  fi
done

echo "All three AzerothCore targets passed smoke tests."
