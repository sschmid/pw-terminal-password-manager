ARG BASH_VERSION=5.2
FROM bash:${BASH_VERSION} AS base
WORKDIR /usr/local/opt/pw
COPY DEPENDENCIES.md .
RUN apk add --no-cache \
    $(cat DEPENDENCIES.md) \
    parallel \
    xclip \
    xvfb

FROM base AS pw
WORKDIR /usr/local/opt/pw
COPY src src
COPY config config
COPY plugins plugins
COPY version.txt .
RUN ln -s /usr/local/opt/pw/src/pw /usr/local/bin/pw
WORKDIR /root
COPY docker/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

FROM pw AS test
WORKDIR /usr/local/opt/pw
COPY test test
RUN test/bats/bin/bats --jobs $(nproc) test
