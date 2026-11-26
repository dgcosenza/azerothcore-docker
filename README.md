# AzerothCore WotLK — Debian 13 (trixie-slim) Images

[![Daily AzerothCore images](https://github.com/dgcosenza/azerothcore-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/azerothcore-docker/actions/workflows/daily.yml)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue.svg)](https://github.com/dgcosenza/azerothcore-docker/blob/main/LICENSE)
[![Upstream License: GPL-2.0-only](https://img.shields.io/badge/upstream-GPL--2.0--only-green.svg)](https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE)
[![Signed with Cosign](https://img.shields.io/badge/signed-cosign%20OIDC-blueviolet.svg)](#supply-chain-verification)
[![SLSA Level 3](https://img.shields.io/badge/SLSA-Level%203-brightgreen.svg)](#supply-chain-verification)
[![Architectures](https://img.shields.io/badge/arch-amd64-informational.svg)](#supported-architectures)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/azerothcore-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/azerothcore-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/ac-wotlk-worldserver)](https://hub.docker.com/r/dgcosenza/ac-wotlk-worldserver)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/ac-wotlk-worldserver/latest)](https://hub.docker.com/r/dgcosenza/ac-wotlk-worldserver)
[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/azerothcore-docker?label=version)](https://github.com/dgcosenza/azerothcore-docker/releases)

Source-built **AzerothCore WotLK** container images (`authserver`, `worldserver`, and `db-import`) compiled with Clang/Ninja on **Debian 13 (`trixie-slim`)**, maintained by **Daniel G. Cosenza from FNX Labs**.

- **Docker Hub Images:**
  - [`dgcosenza/ac-wotlk-worldserver`](https://hub.docker.com/r/dgcosenza/ac-wotlk-worldserver)
  - [`dgcosenza/ac-wotlk-authserver`](https://hub.docker.com/r/dgcosenza/ac-wotlk-authserver)
  - [`dgcosenza/ac-wotlk-db-import`](https://hub.docker.com/r/dgcosenza/ac-wotlk-db-import)
- **GitHub Container Registry (GHCR):** [`ghcr.io/dgcosenza/ac-wotlk-worldserver`](https://github.com/dgcosenza/azerothcore-docker/pkgs/container/ac-wotlk-worldserver) (identical signed multi-arch digest)
- **Source Repository:** [`dgcosenza/azerothcore-docker`](https://github.com/dgcosenza/azerothcore-docker)
- **Upstream Application:** [`azerothcore/azerothcore-wotlk`](https://github.com/azerothcore/azerothcore-wotlk) (AGPL-3.0 / GPL-2.0)
- **Packaging License:** MIT (see [`LICENSE`](https://github.com/dgcosenza/azerothcore-docker/blob/main/LICENSE) and [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/azerothcore-docker/blob/main/THIRD-PARTY-NOTICES.md))

---

## Overview

`dgcosenza/azerothcore-docker` compiles `azerothcore/azerothcore-wotlk` `master` together with the official Lua engine module [`azerothcore/mod-ale`](https://github.com/azerothcore/mod-ale) (matching upstream `acore/ac-wotlk-*` official container builds) from source with Clang 19, `lld`, CMake, Ninja, and statically linked Boost on **Debian 13 (`trixie-slim`)**, publishing three minimal runtime images with full drop-in compatibility:

- **Exact path & entrypoint parity:** Preserves `/azerothcore/entrypoint.sh`, `/azerothcore/env/dist/bin/{authserver,worldserver,dbimport}`, `/azerothcore/env/dist/{etc,data,logs,temp}`, `/azerothcore/env/ref/etc`, non-root user `acore` (UID/GID `1000:1000`), and `mysql`/`mysqladmin` clients for startup wait scripts.
- **Hardened & CVE-gated (all severities with a fix):** Compilers and build headers stay strictly in the `build` stage; runtime images ship `tini` as PID 1, run as non-root `acore` with `no-new-privileges:true`, and enforce **0 fixable findings of any severity** findings in both Trivy and Grype across all three images.

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| AzerothCore | `17.0.0-dev (5aa4795)` |
| Modules | `mod-ale (84b85cc)` |
| Targets | `authserver, worldserver, db-import` |
| MySQL Client | `Oracle MySQL 8.4 LTS` |
| Base OS | `Debian 13.8 (trixie-slim)` |
| Architectures | `linux/amd64` |
| Uncompressed size (per arch) | `amd64: 200.3 MB` |
| Last verified build (UTC) | `2026-11-25` |
| Published multi-arch digest | `dgcosenza/ac-wotlk-worldserver@sha256:5dc05b7333cb3d1c8121639bf05d393a2c15601177207e7b702989f4b172c204` |
| GHCR mirror | `ghcr.io/dgcosenza/ac-wotlk-worldserver@sha256:5dc05b7333cb3d1c8121639bf05d393a2c15601177207e7b702989f4b172c204` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable findings of any severity** (13 upstream-unfixed) |
<!-- versions:end -->

---

## Supported Tags

Each of the three repositories (`ac-wotlk-worldserver`, `ac-wotlk-authserver`, `ac-wotlk-db-import`) publishes:

| Tag | Policy | Description |
| --- | --- | --- |
| `<version>-<commit>-<YYYYMMDD>` | **Immutable** | Point-in-time build pinning the upstream commit and UTC date. |
| `<version>-<YYYYMMDD>` | **Immutable** | Date-stamped daily rebuild. |
| `sha-<short>` | **Immutable** | Packaging repository Git commit tag. |
| `<version>` (e.g. `17.0.0-dev`) | Moving | Latest verified Debian 13 build tracking upstream `master`. |
| `latest` | Moving | Latest verified build. |

**Production pinning:** Pin all three services by matching digest from the same build run so `db-import`, `authserver`, and `worldserver` stay schema-aligned:

```yaml
image: dgcosenza/ac-wotlk-worldserver:latest@sha256:<digest>
```

---

## Supported Architectures

| Architecture | Status | Verification |
| --- | --- | --- |
| `linux/amd64` | **Published & natively tested** | Built, smoke-tested, Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native x86_64 CI runners. |
| `linux/arm64` | **Not supported (upstream limitation)** | Upstream `acore/ac-wotlk-*` images and Oracle's official Debian 13 (`trixie`) MySQL 8.4 LTS APT repository (`libmysqlclient-dev` / `libmysqlclient24` required by AzerothCore's C API) ship `amd64` binaries only. |

Identical signed OCI digests are published to **Docker Hub** and **GHCR** (`ghcr.io/dgcosenza/ac-wotlk-*`), accompanied by automated signed [GitHub Releases](https://github.com/dgcosenza/azerothcore-docker/releases).
---

## Quick Start

See [`docker-compose.example.yml`](https://github.com/dgcosenza/azerothcore-docker/blob/main/docker-compose.example.yml).

> **CRITICAL WARNING:** Never run `docker compose down` or `docker compose down -v` / `up -V` on an existing AzerothCore stack if your customized `worldserver.conf` or `authserver.conf` lives in an anonymous Docker volume mounted at `/azerothcore/env/dist/etc`. Always recreate services individually with `docker compose up -d --no-deps <service>` after backing up both the database and `/azerothcore/env/dist/etc`.

---

## Configuration

### Environment Variables

All upstream `AC_*` configuration overrides (e.g., `AC_LOGIN_DATABASE_INFO`, `AC_WORLD_DATABASE_INFO`, `AC_CHARACTER_DATABASE_INFO`, `AC_DATA_DIR`, `AC_LOGS_DIR`, `AC_UPDATES_ENABLE_DATABASES`, `AC_UPDATES_AUTO_SETUP`, `AC_DISABLE_INTERACTIVE`) work identically to `acore/ac-wotlk-*`.

### Volumes, Ports, and UID/GID

| Target | Port | Key Paths | User |
| --- | --- | --- | --- |
| `ac-wotlk-authserver` | `3724/tcp` | `/azerothcore/env/dist/etc`, `/azerothcore/env/dist/logs` | `acore` (`1000:1000`) |
| `ac-wotlk-worldserver` | `8085/tcp` | `/azerothcore/env/dist/etc`, `/azerothcore/env/dist/data` | `acore` (`1000:1000`) |
| `ac-wotlk-db-import` | *(none)* | `/azerothcore/data`, `/azerothcore/modules` | `acore` (`1000:1000`) |

---

## Healthcheck

- **`authserver`:** `bash -c 'exec 3<>/dev/tcp/127.0.0.1/3724'`
- **`worldserver`:** `bash -c 'exec 3<>/dev/tcp/127.0.0.1/8085'`
- **`db-import`:** `pgrep -x dbimport` (verifies the import process is running; `--interval=10s --timeout=5s --start-period=5s --retries=3`)
- **Timings:** authserver `30s/10s/120s/3`, worldserver `30s/10s/300s/3` (interval/timeout/start-period/retries).
- **CI validation:** every build starts all three targets and waits for Docker to report `status=healthy` before publishing. Because CI has no game database, the probe condition is satisfied by a small static test stub (`tests/health-stub.c`) that listens on the expected loopback port or idles under the `dbimport` process name; the Dockerfile HEALTHCHECK instruction itself is exercised unchanged. Real binaries, non-root `1000:1000`, `tini` PID 1 and library resolution are verified separately by `tests/smoke.sh`.

---

## Upgrading and Migrating from `acore/ac-wotlk-*`

1. Dump all AzerothCore databases (`acore_auth`, `acore_world`, `acore_characters`) and back up `/azerothcore/env/dist/etc` volumes before changing any image.
2. Tag outgoing images for rollback (`local/acore-rollback:<date>`).
3. Update `ac-db-import`, `ac-authserver`, and `ac-worldserver` to matching digests from the same build run.
4. Recreate one service at a time (`docker compose run --rm ac-db-import`, then `docker compose up -d --no-deps ac-authserver`, then `docker compose up -d --no-deps ac-worldserver`) — **never** `docker compose down` or `-V`.

---

## Supply-Chain Verification

Every published digest (multi-arch index and per-architecture manifests) on both Docker Hub and GHCR is keyless-signed with **Sigstore Cosign** (GitHub OIDC), attested with **SPDX** and **CycloneDX** SBOMs, and backed by **SLSA Build L3** provenance (`actions/attest-build-provenance`).

### Verify image signature with Cosign

```bash
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/azerothcore-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/ac-wotlk-worldserver:latest

# Or against Docker Hub (identical digest):
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/azerothcore-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  dgcosenza/ac-wotlk-worldserver:latest
```

### Verify SPDX / CycloneDX SBOM attestations and SLSA Build Provenance

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/azerothcore-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/ac-wotlk-worldserver@sha256:<arch-digest>

gh attestation verify oci://ghcr.io/dgcosenza/ac-wotlk-worldserver:latest --owner dgcosenza
```

---

## Security

- **Vulnerability scan policy (all severities with a fix):** Every CI build scans all three targets (`authserver`, `worldserver`, `db-import`) with **Trivy** (table, JSON, SARIF upload, blocking `--ignore-unfixed` gate) and **Grype** (`--only-fixed`, severity cutoff `negligible`, blocking gate), and emits **SPDX SBOM** artifacts.
- **Current status:** **0 fixable findings of any severity** vulnerabilities across all three Debian 13 runtime images.
- **Non-root & minimal runtime:** Runs as `acore` (UID/GID `1000:1000`) with `tini` PID 1 and `no-new-privileges:true`; compilers (`clang`, `cmake`, `ninja`, `ccache`, `-dev` headers) are excluded from all runtime images.
- See [`SECURITY.md`](https://github.com/dgcosenza/azerothcore-docker/blob/main/SECURITY.md).

---

## Build Locally

```bash
git clone https://github.com/dgcosenza/azerothcore-docker.git
cd azerothcore-docker

for target in authserver worldserver db-import; do
  docker buildx build \
    --platform linux/amd64 \
    --target "$target" \
    --load \
    -t "dgcosenza/ac-wotlk-${target}:local" \
    .
done
```

| Build Arg | Default | Purpose |
| --- | --- | --- |
| `AZEROTHCORE_COMMIT` | `3a25f726ed68c5f2c361455ee9cd985fe929c3e9` | Pinned `azerothcore-wotlk` commit SHA (resolved daily by CI). |
| `AZEROTHCORE_VERSION` | `17.0.0-dev` | Upstream release line label. |
| `DEBIAN_BASE` | `debian:trixie-slim` | Base OS image. |
| `CTYPE` | `RelWithDebInfo` | CMake build type. |

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/azerothcore-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **05:25 UTC**, on pushes to `main`, on pull requests (verification only), and via `workflow_dispatch`. Every scheduled run executes a seven-step automated pipeline (gated by `.github/workflows/public-check.yml`):

1. **Upstream check:** Resolves the latest `azerothcore/azerothcore-wotlk` `master` commit and `debian:trixie-slim` digest, diffs against `versions.json`, fetches recent commit summaries via the authenticated GitHub API, and emits `upstream-changes.md`.
2. **Cached / scheduled no-cache rebuild:** Builds all three targets (`authserver`, `worldserver`, `db-import`) with `--no-cache` on scheduled daily runs and Buildx/ccache acceleration on push/PR builds, upgrading Debian 13 packages and emitting **SPDX SBOM** and provenance artifacts.
3. **Vulnerability fix and gate:** Scans all three targets with **Trivy** (table, JSON, SARIF upload, blocking `--ignore-unfixed` gate) and **Grype** (blocking `--only-fixed` gate, severity cutoff `negligible`), diffs CVEs against the previous scan, and retains reports for 90 days.
4. **Smoke test:** Runs [`tests/smoke.sh`](https://github.com/dgcosenza/azerothcore-docker/blob/main/tests/smoke.sh) across all three targets (UID/GID `1000`, `tini` PID 1, `mysql`/`mysqladmin`, `ldd` linkage, `--version`/`--help`, non-clobbering `entrypoint.sh` config seeding, negative TCP healthcheck).
5. **Publish:** On non-PR builds when Docker Hub secrets are configured, pushes matching tags to `dgcosenza/ac-wotlk-authserver`, `dgcosenza/ac-wotlk-worldserver`, and `dgcosenza/ac-wotlk-db-import` and records the worldserver digest.
6. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry via `github-actions[bot]` with `[skip ci]` when content changes, then syncs Docker Hub descriptions for all three repositories via `peter-evans/dockerhub-description`.
7. **Failure alerting:** On failure, CI opens or updates a single GitHub issue labeled `ci-failure` with the failing job and run link, and auto-closes it on the next green run.

---

## Design Decisions

- **Debian 13 (`trixie-slim`) with Clang 19 + lld + Ninja + static Boost + Oracle MySQL 8.4 LTS client:** Replaces the Ubuntu 24.04 upstream base with a lean Debian 13 runtime (`libmysqlclient24`, `mysql-client`, `libreadline8t64`, `libicu76`, `libzstd1`) verified against Oracle's official APT signing key while preserving full `mysql`/`mysqladmin` wait-script and C API compatibility.
- **Single multi-target Dockerfile:** Compiles AzerothCore once in the `build` stage and packages `authserver`, `worldserver`, and `db-import` cleanly from the exact same revision.

---

## License

This repository follows a clear packaging-vs-upstream license split:

- **Container packaging, scripts, CI workflows, and documentation (`packaging: MIT`):** Licensed under the [MIT License](https://github.com/dgcosenza/azerothcore-docker/blob/main/LICENSE) — copyright **Daniel G. Cosenza from FNX Labs**.
- **Bundled upstream software — AzerothCore WotLK (`azerothcore/azerothcore-wotlk`) (`upstream: GPL-2.0-only`):** AzerothCore WotLK is licensed under the [GNU General Public License v2.0 (`GPL-2.0-only`)](https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE).

Full third-party notices are maintained in [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/azerothcore-docker/blob/main/THIRD-PARTY-NOTICES.md). Release history is maintained in [`CHANGELOG.md`](https://github.com/dgcosenza/azerothcore-docker/blob/main/CHANGELOG.md).
