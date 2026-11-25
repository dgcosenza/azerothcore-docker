# syntax=docker/dockerfile:1.7

ARG DEBIAN_BASE=debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0
ARG AZEROTHCORE_COMMIT=3a25f726ed68c5f2c361455ee9cd985fe929c3e9
ARG AZEROTHCORE_VERSION=17.0.0-dev

# ---- Stage 0: shared directory skeleton + GPG-verified Oracle MySQL 8.4 LTS APT repo ----
FROM ${DEBIAN_BASE} AS skeleton
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TZ=Etc/UTC
ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=${TZ} \
    AC_FORCE_CREATE_DB=1

RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends ca-certificates curl gpg tzdata; \
    install -d -m 0755 /etc/apt/keyrings; \
    install -d -m 0700 /tmp/gnupg; \
    curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2025 -o /etc/apt/keyrings/mysql.asc; \
    FPR="$(gpg --homedir /tmp/gnupg --show-keys --with-colons /etc/apt/keyrings/mysql.asc | awk -F: '/^fpr:/{print $10; exit}')"; \
    test "${FPR}" = "BCA43417C3B485DD128EC6D4B7B3B788A8D3785C"; \
    rm -rf /tmp/gnupg; \
    printf 'Types: deb\nURIs: https://repo.mysql.com/apt/debian\nSuites: trixie\nComponents: mysql-8.4-lts\nSigned-By: /etc/apt/keyrings/mysql.asc\n' \
      > /etc/apt/sources.list.d/mysql.sources; \
    apt-get purge -y --auto-remove curl gpg; \
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime; \
    echo "${TZ}" > /etc/timezone; \
    mkdir -p \
      /azerothcore/bin \
      /azerothcore/data \
      /azerothcore/deps \
      /azerothcore/env/dist/bin \
      /azerothcore/env/dist/data/Cameras \
      /azerothcore/env/dist/data/dbc \
      /azerothcore/env/dist/data/maps \
      /azerothcore/env/dist/data/mmaps \
      /azerothcore/env/dist/data/vmaps \
      /azerothcore/env/dist/logs \
      /azerothcore/env/dist/temp \
      /azerothcore/env/dist/etc \
      /azerothcore/env/ref/etc \
      /azerothcore/modules \
      /azerothcore/src \
      /azerothcore/build; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /azerothcore

# ---- Stage 1: compile AzerothCore (authserver, worldserver, dbimport) on Debian 13 ----
FROM skeleton AS build
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG AZEROTHCORE_COMMIT
ARG CTYPE="RelWithDebInfo"
ARG CSCRIPTS="static"
ARG CMODULES="static"
ARG CTOOLS_BUILD="db-only"
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      build-essential ccache clang cmake cmake-data curl \
      git libboost-all-dev libbz2-dev liblzma-dev libmysqlclient-dev \
      libncurses-dev libreadline-dev libssl-dev libtool libzstd-dev lld \
      mysql-client ninja-build openssl pkg-config unzip zlib1g-dev; \
    rm -rf /var/lib/apt/lists/*; \
    git init /tmp/ac-src; \
    git -C /tmp/ac-src remote add origin https://github.com/azerothcore/azerothcore-wotlk.git; \
    git -C /tmp/ac-src fetch --depth 1 origin "${AZEROTHCORE_COMMIT}"; \
    git -C /tmp/ac-src checkout --detach FETCH_HEAD; \
    test "$(git -C /tmp/ac-src rev-parse HEAD)" = "${AZEROTHCORE_COMMIT}"; \
    cp -a /tmp/ac-src/CMakeLists.txt /azerothcore/CMakeLists.txt; \
    cp -a /tmp/ac-src/apps /azerothcore/apps; \
    cp -a /tmp/ac-src/conf /azerothcore/conf; \
    cp -a /tmp/ac-src/data/. /azerothcore/data/; \
    cp -a /tmp/ac-src/deps/. /azerothcore/deps/; \
    cp -a /tmp/ac-src/src/. /azerothcore/src/; \
    cp -a /tmp/ac-src/modules/. /azerothcore/modules/; \
    cp -a /tmp/ac-src/.git /azerothcore/.git; \
    rm -rf /tmp/ac-src

WORKDIR /azerothcore/build

RUN --mount=type=cache,target=/ccache,sharing=locked \
    set -eux; \
    export CCACHE_DIR=/ccache; \
    export CCACHE_MAXSIZE=2G; \
    export CCACHE_SLOPPINESS=pch_defines,time_macros,include_file_mtime; \
    git config --global --add safe.directory /azerothcore; \
    cmake /azerothcore \
      -G Ninja \
      -DCMAKE_INSTALL_PREFIX="/azerothcore/env/dist" \
      -DAPPS_BUILD="all" \
      -DTOOLS_BUILD="${CTOOLS_BUILD}" \
      -DSCRIPTS="${CSCRIPTS}" \
      -DMODULES="${CMODULES}" \
      -DWITH_WARNINGS="OFF" \
      -DCMAKE_BUILD_TYPE="${CTYPE}" \
      -DCMAKE_CXX_COMPILER="clang++" \
      -DCMAKE_C_COMPILER="clang" \
      -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" \
      -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" \
      -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
      -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
      -DBoost_USE_STATIC_LIBS="ON"; \
    cmake --build . --config "${CTYPE}" -j"$(nproc)"; \
    cmake --install . --config "${CTYPE}"; \
    rm -rf /azerothcore/.git

# ---- Stage 2: shared hardened Debian 13 runtime ----
FROM skeleton AS runtime

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG DOCKER_USER=acore
ARG DEBIAN_FRONTEND=noninteractive

ENV ACORE_COMPONENT=undefined \
    PATH="/azerothcore/env/dist/bin:${PATH}"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      bash gettext-base libbz2-1.0 libicu76 liblzma5 libmysqlclient24 \
      libncurses6 libreadline8t64 libssl3t64 libzstd1 mysql-client \
      passwd procps tini zlib1g; \
    groupadd --gid "${GROUP_ID}" "${DOCKER_USER}"; \
    useradd --uid "${USER_ID}" --gid "${GROUP_ID}" --create-home \
      --shell /bin/bash --comment 'AzerothCore service user' "${DOCKER_USER}"; \
    chown -R "${USER_ID}:${GROUP_ID}" /azerothcore; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build --chown=${USER_ID}:${GROUP_ID} /azerothcore/env/dist/etc/ /azerothcore/env/ref/etc/
COPY --chown=${USER_ID}:${GROUP_ID} --chmod=0755 scripts/entrypoint.sh /azerothcore/entrypoint.sh

VOLUME ["/azerothcore/env/dist/etc"]
USER ${DOCKER_USER}
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/bin/env", "bash", "/azerothcore/entrypoint.sh"]

# ---- Target: authserver ----
FROM runtime AS authserver

ARG AZEROTHCORE_VERSION
ARG AZEROTHCORE_COMMIT
ARG BUILD_DATE=unknown
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/azerothcore-docker"

ENV ACORE_COMPONENT=authserver \
    AC_UPDATES_ENABLE_DATABASES=0 \
    AC_DISABLE_INTERACTIVE=1 \
    AC_CLOSE_IDLE_CONNECTIONS=0

COPY --from=build --chown=1000:1000 /azerothcore/env/dist/bin/authserver /azerothcore/env/dist/bin/authserver

EXPOSE 3724

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD ["bash", "-c", "exec 3<>/dev/tcp/127.0.0.1/3724"]

CMD ["authserver"]

LABEL org.opencontainers.image.title="AzerothCore WotLK Authserver (Debian 13)" \
      org.opencontainers.image.description="Source-built AzerothCore WotLK authserver on Debian 13 (trixie-slim, linux/amd64), maintained by Daniel G. Cosenza from FNX Labs." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/ac-wotlk-authserver" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${AZEROTHCORE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.licenses="GPL-2.0-only AND MIT" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.base.name="debian:trixie-slim" \
      io.github.dgcosenza.azerothcore.component="authserver" \
      io.github.dgcosenza.azerothcore.upstream_commit="${AZEROTHCORE_COMMIT}"

# ---- Target: worldserver ----
FROM runtime AS worldserver

ARG AZEROTHCORE_VERSION
ARG AZEROTHCORE_COMMIT
ARG BUILD_DATE=unknown
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/azerothcore-docker"

ENV ACORE_COMPONENT=worldserver \
    AC_UPDATES_ENABLE_DATABASES=0 \
    AC_DISABLE_INTERACTIVE=1 \
    AC_CLOSE_IDLE_CONNECTIONS=0

COPY --from=build --chown=1000:1000 /azerothcore/env/dist/bin/worldserver /azerothcore/env/dist/bin/worldserver

EXPOSE 8085
VOLUME ["/azerothcore/env/dist/etc"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=3 \
    CMD ["bash", "-c", "exec 3<>/dev/tcp/127.0.0.1/8085"]

CMD ["worldserver"]

LABEL org.opencontainers.image.title="AzerothCore WotLK Worldserver (Debian 13)" \
      org.opencontainers.image.description="Source-built AzerothCore WotLK worldserver on Debian 13 (trixie-slim, linux/amd64), maintained by Daniel G. Cosenza from FNX Labs." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/ac-wotlk-worldserver" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${AZEROTHCORE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.licenses="GPL-2.0-only AND MIT" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.base.name="debian:trixie-slim" \
      io.github.dgcosenza.azerothcore.component="worldserver" \
      io.github.dgcosenza.azerothcore.upstream_commit="${AZEROTHCORE_COMMIT}"

# ---- Target: db-import ----
FROM runtime AS db-import

ARG AZEROTHCORE_VERSION
ARG AZEROTHCORE_COMMIT
ARG BUILD_DATE=unknown
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/azerothcore-docker"

ENV ACORE_COMPONENT=dbimport

COPY --from=build --chown=1000:1000 /azerothcore/data /azerothcore/data
COPY --from=build --chown=1000:1000 /azerothcore/modules /azerothcore/modules
COPY --from=build --chown=1000:1000 /azerothcore/env/dist/bin/dbimport /azerothcore/env/dist/bin/dbimport

CMD ["/azerothcore/env/dist/bin/dbimport"]

LABEL org.opencontainers.image.title="AzerothCore WotLK DB Import (Debian 13)" \
      org.opencontainers.image.description="Source-built AzerothCore WotLK database import tool on Debian 13 (trixie-slim, linux/amd64), maintained by Daniel G. Cosenza from FNX Labs." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/ac-wotlk-db-import" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${AZEROTHCORE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.licenses="GPL-2.0-only AND MIT" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.base.name="debian:trixie-slim" \
      io.github.dgcosenza.azerothcore.component="db-import" \
      io.github.dgcosenza.azerothcore.upstream_commit="${AZEROTHCORE_COMMIT}"
