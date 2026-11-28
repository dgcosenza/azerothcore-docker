# Changelog

All notable changes to the `dgcosenza/ac-wotlk-*` Debian 13 container packaging and CI workflows are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Maintained by **Daniel G. Cosenza from FNX Labs**.

---
<!-- changelog:auto -->

## [17.0.0-dev-0456e5c] — 2026-11-28

### Automated Daily Build
- Verified components: AzerothCore `17.0.0-dev (0456e5c)`, Modules `mod-ale (a186f59)`, Targets `authserver, worldserver, db-import`, MySQL Client `Oracle MySQL 8.4 LTS`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64` (native smoke tests + Dive efficiency gate).
- Upstream changes:
  - AzerothCore master advanced from 65e5a98 to 0456e5c.
  - 57d7b10: fix(Core/Vehicle): Keep a player vehicle's passengers across a map change (#28590)
  - 54dc2f3: fix(Core/Spells): Fix autocast conditions and stacking for hunter pet abilities (#27422)
  - 14e95f0: fix(Core/Guild): Show items put in a new bank tab (#28586)
  - 5b770cc: fix(Core/Petitions): Keep unsigned charters signable after restart (#28589)
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/ac-wotlk-worldserver@sha256:adf93462d220db4438bd0d9a3a400703a05e7bb0da7aef25956a57cfd29a7d65` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).

---

## [17.0.0-dev-65e5a98] — 2026-11-27

### Automated Daily Build
- Verified components: AzerothCore `17.0.0-dev (65e5a98)`, Modules `mod-ale (a186f59)`, Targets `authserver, worldserver, db-import`, MySQL Client `Oracle MySQL 8.4 LTS`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64` (native smoke tests + Dive efficiency gate).
- Upstream changes:
  - AzerothCore master advanced from 8e27b16 to 65e5a98.
  - 8fc3b09: fix(Core/Pet): Avoid cooldowns on failed casts (#27170)
  - 65e5a98: feat(CI): List failed e2e tests on the run summary (#28585)
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/ac-wotlk-worldserver@sha256:f27569b557603516b824acbe2950a374aab72c22b889aee7c46c319046279ce9` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [17.0.0-dev-cda3f63] — 2026-11-26

### Automated Daily Build
- Verified components: AzerothCore `17.0.0-dev (cda3f63)`, Modules `mod-ale (84b85cc)`, Targets `authserver, worldserver, db-import`, MySQL Client `Oracle MySQL 8.4 LTS`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64` (native smoke tests + Dive efficiency gate).
- Upstream status: no new upstream release since previous build; refreshed base OS and dependencies.
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/ac-wotlk-worldserver@sha256:dbaadd6fb194eeef4557b394a9b486b91bd5e31aede26de6ee9ddb79b120307f` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
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
