# Third-Party Notices

This repository builds container images for open-source software maintained by third parties alongside Debian 13 container packaging by **Daniel G. Cosenza from FNX Labs**.

## AzerothCore (WotLK)
- **Project:** [`azerothcore/azerothcore-wotlk`](https://github.com/azerothcore/azerothcore-wotlk)
- **License:** GNU Affero General Public License v3.0 / GNU General Public License v2.0 (see upstream [`COPYING`](https://github.com/azerothcore/azerothcore-wotlk/blob/master/COPYING))

## Base Image & Runtime Components
- **Oracle MySQL 8.4 LTS Client (`libmysqlclient24`, `mysql-client`):** Distributed by Oracle under GNU General Public License v2.0 (with FOSS License Exception) via the official GPG-verified Debian 13 (`trixie`) APT repository (`repo.mysql.com`).
- **Debian 13 (`trixie-slim`) packages (`libreadline8t64`, `libicu76`, `libssl3t64`, `tini`, etc.):** Distributed under their respective free software licenses recorded in `/usr/share/doc/*/copyright` inside each image.
