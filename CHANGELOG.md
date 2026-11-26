# Changelog

All notable changes to the `dgcosenza/ac-wotlk-*` Debian 13 container packaging and CI workflows are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Maintained by **Daniel G. Cosenza from FNX Labs**.

---
<!-- changelog:auto -->

## [17.0.0-dev-cda3f63] — 2026-11-26

### Automated Daily Build
- Verified components: AzerothCore `17.0.0-dev (cda3f63)`, Modules `mod-ale (84b85cc)`, Targets `authserver, worldserver, db-import`, MySQL Client `Oracle MySQL 8.4 LTS`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64` (native smoke tests + Dive efficiency gate).
- Upstream changes:
  - AzerothCore master advanced from 0288e0f to cda3f63.
  - b4cbbfb: fix(Scripts/TrialOfTheCrusader): Stop spike chase and spline (#28582)
  - a52dffd: fix(DB/Creature): Make Coilfang Frenzy Corpse unattackable (#28584)
  - 192690e: chore(DB): import pending files
  - cda3f63: fix(Core/Creature): Don't make rooted creatures fall on death (#28583)
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/ac-wotlk-worldserver@sha256:7575bc0d190d168ce7c18ce173298d58019156c369a65847602f4886272ce7b6` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [17.0.0-dev-5aa4795] — 2026-11-25

### Automated Daily Build
- Verified components: AzerothCore `17.0.0-dev (5aa4795)`, Modules `mod-ale (84b85cc)`, Targets `authserver, worldserver, db-import`, MySQL Client `Oracle MySQL 8.4 LTS`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64` (native smoke tests + Dive efficiency gate).
- Upstream status: no new upstream release since previous build; refreshed base OS and dependencies.
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/ac-wotlk-worldserver@sha256:5dc05b7333cb3d1c8121639bf05d393a2c15601177207e7b702989f4b172c204` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [17.0.0-dev-3a25f72] — 2026-11-24

### Added
- Initial multi-target **Debian 13 (`trixie-slim`)** source build for **AzerothCore WotLK** (`authserver`, `worldserver`, and `db-import`) compiled with Clang 19, Ninja, and statically linked Boost.
- Full drop-in parity with `acore/ac-wotlk-*` (`/azerothcore/entrypoint.sh`, `/azerothcore/env/dist/*`, non-root `acore` UID/GID `1000`, `mysql`/`mysqladmin` clients, `tini` PID 1, `no-new-privileges:true`, TCP healthchecks).
- Seven-step automated daily CI pipeline (`.github/workflows/daily.yml`) with Buildx/ccache caching, Trivy and Grype fixable Critical/High blocking gates on all three images, Syft SPDX SBOMs, smoke tests (`tests/smoke.sh`), automated docs/Hub sync, and `ci-failure` issue alerting.
