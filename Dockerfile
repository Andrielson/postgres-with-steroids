# syntax=docker/dockerfile:1
###
### PG DUCKDB BUILDER
###
FROM ghcr.io/andrielson/postgres:17-noble AS pg-duckdb-builder

ENV PATH=/usr/lib/ccache:$PATH
ENV CCACHE_DIR=/ccache

WORKDIR /build

RUN set -ex; \
    apt-get -qqy --fix-missing update; \
    apt-get -qqy --fix-missing install \
    postgresql-server-dev-17 \
    build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev \
    libssl-dev libxml2-utils xsltproc pkg-config libc++-dev libc++abi-dev libglib2.0-dev \
    libtinfo6 cmake libstdc++-12-dev liblz4-dev ccache ninja-build git zip && \
    mkdir /ccache /out; \
    git clone --recurse-submodules https://github.com/duckdb/pg_duckdb.git .; \
    make clean-all; \
    echo "Available CPUs=$(nproc)"; \
    make -j$(nproc); \
    DESTDIR=/out make install; \
    cp ./docker/init.d/* /docker-entrypoint-initdb.d/; \
    cd /out; \
    zip -0 -r pg_duckdb.zip ./usr /docker-entrypoint-initdb.d;

###
### FINAL IMAGE
###
FROM ghcr.io/andrielson/postgres:17-noble

COPY --from=pg-duckdb-builder /out/pg_duckdb.zip /tmp/pg_duckdb.zip

# Install OpenSSL and useful extensions then
# Allow the postgres user to execute certain commands as root without a password
RUN set -ex; \
    apt-get -qqy --fix-missing update; \
    apt-get -qqy --fix-missing install --no-install-recommends \
    ca-certificates \
    curl \
    nano \
    openssl \
    postgresql-17-age \
    postgresql-17-h3 \
    postgresql-17-pgvector \
    postgresql-17-postgis-3 \
    postgresql-17-timescaledb \
    postgresql-plpython3-17 \
    sudo \
    unzip \
    wget; \
    apt-get -qqy --fix-missing dist-upgrade; \
    unzip -oqq /tmp/pg_duckdb.zip -d /; \
    wget --quiet --output-document=/tmp/supabase-wrappers.deb https://github.com/supabase/wrappers/releases/download/v0.5.1/wrappers-v0.5.1-pg17-amd64-linux-gnu.deb; \
    dpkg --install /tmp/supabase-wrappers.deb; \
    echo "postgres ALL=(root) NOPASSWD: /usr/bin/mkdir, /bin/chown, /usr/bin/openssl" > /etc/sudoers.d/postgres; \
	echo "shared_preload_libraries='pg_duckdb'" >> /usr/share/postgresql/postgresql.conf.sample; \
    rm -rf /var/lib/apt/lists/* /tmp/pg_duckdb.zip /tmp/supabase-wrappers.deb;

# Add init scripts while setting permissions
COPY --chmod=755 init-ssl.sh /docker-entrypoint-initdb.d/init-ssl.sh
COPY --chmod=755 wrapper.sh /usr/local/bin/wrapper.sh

ENTRYPOINT ["wrapper.sh"]
CMD ["postgres", "-p", "5432", "-c", "listen_addresses=*"]