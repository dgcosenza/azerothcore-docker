# Changelog

All notable changes to the `dgcosenza/ac-wotlk-*` Debian 13 container packaging and CI workflows are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Maintained by **Daniel G. Cosenza from FNX Labs**.

---
<!-- changelog:auto -->

## [17.0.0-dev-3a25f72] — 2026-11-25

### Automated Daily Build
- Verified components: AzerothCore `17.0.0-dev (3a25f72)`, Targets `authserver, worldserver, db-import`, MySQL Client `Oracle MySQL 8.4 LTS`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64` (native smoke tests + Dive efficiency gate).
- Upstream status: no new upstream release since previous build; refreshed base OS and dependencies.
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/ac-wotlk-worldserver@sha256:33124306db83be9f2d6b4191f15c8e4e90b5cb867a46a3b43e91dd9bda3b9e49` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).

---

## [17.0.0-dev-3a25f72] — 2026-11-24

### Added
- Initial multi-target **Debian 13 (`trixie-slim`)** source build for **AzerothCore WotLK** (`authserver`, `worldserver`, and `db-import`) compiled with Clang 19, Ninja, and statically linked Boost.
- Full drop-in parity with `acore/ac-wotlk-*` (`/azerothcore/entrypoint.sh`, `/azerothcore/env/dist/*`, non-root `acore` UID/GID `1000`, `mysql`/`mysqladmin` clients, `tini` PID 1, `no-new-privileges:true`, TCP healthchecks).
- Seven-step automated daily CI pipeline (`.github/workflows/daily.yml`) with Buildx/ccache caching, Trivy and Grype fixable Critical/High blocking gates on all three images, Syft SPDX SBOMs, smoke tests (`tests/smoke.sh`), automated docs/Hub sync, and `ci-failure` issue alerting.
