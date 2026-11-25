# Changelog

All notable changes to the `dgcosenza/ac-wotlk-*` Debian 13 container packaging and CI workflows are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Maintained by **Daniel G. Cosenza from FNX Labs**.

---
<!-- changelog:auto -->

## [17.0.0-dev-5aa4795] — 2026-11-25

### Automated Daily Build
- Verified components: AzerothCore `17.0.0-dev (5aa4795)`, Modules `mod-ale (84b85cc)`, Targets `authserver, worldserver, db-import`, MySQL Client `Oracle MySQL 8.4 LTS`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64` (native smoke tests + Dive efficiency gate).
- Upstream changes:
  - AzerothCore master advanced from 66299e6 to 5aa4795.
  - 6142835: fix(DB/Creature): Make Bountiful Table Hostess immune to PCs and NPCs (#28571)
  - c846d32: fix(Scripts/TheEye): Skip Al'ar Berserk on death (#28570)
  - 5aa4795: chore(DB): import pending files
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/ac-wotlk-worldserver@sha256:118300ca29708132dbfe9709faa90788536334f5a3bce37a10649f87d9777581` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [17.0.0-dev-3a25f72] — 2026-11-24

### Added
- Initial multi-target **Debian 13 (`trixie-slim`)** source build for **AzerothCore WotLK** (`authserver`, `worldserver`, and `db-import`) compiled with Clang 19, Ninja, and statically linked Boost.
- Full drop-in parity with `acore/ac-wotlk-*` (`/azerothcore/entrypoint.sh`, `/azerothcore/env/dist/*`, non-root `acore` UID/GID `1000`, `mysql`/`mysqladmin` clients, `tini` PID 1, `no-new-privileges:true`, TCP healthchecks).
- Seven-step automated daily CI pipeline (`.github/workflows/daily.yml`) with Buildx/ccache caching, Trivy and Grype fixable Critical/High blocking gates on all three images, Syft SPDX SBOMs, smoke tests (`tests/smoke.sh`), automated docs/Hub sync, and `ci-failure` issue alerting.
