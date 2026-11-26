# Security Policy

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Supported Versions

Only the latest daily builds of `dgcosenza/ac-wotlk-authserver`, `dgcosenza/ac-wotlk-worldserver`, and `dgcosenza/ac-wotlk-db-import` compiled from `azerothcore/azerothcore-wotlk` on Debian 13 (`trixie-slim`) receive automated security rebuilds.

## Automated Vulnerability Scanning

Every build in GitHub Actions scans all three runtime targets (`authserver`, `worldserver`, `db-import`) with:
- **Trivy** (`--ignore-unfixed`, all severities `UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL`) blocking gate + table/JSON reports + SARIF upload to GitHub Code Scanning.
- **Grype** (`--only-fixed --fail-on negligible`, all severities) blocking gate + persisted report artifacts.
- **Syft** SPDX SBOM artifacts for all three images.

## Reporting a Vulnerability

- **Container packaging or CI issues:** Open a private security advisory via GitHub Security Advisories on [`dgcosenza/azerothcore-docker`](https://github.com/dgcosenza/azerothcore-docker/security/advisories/new).
- **Upstream AzerothCore issues:** Report via [`azerothcore/azerothcore-wotlk`](https://github.com/azerothcore/azerothcore-wotlk/security/policy).
