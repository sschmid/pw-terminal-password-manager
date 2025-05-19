FROM debian:latest AS base
WORKDIR /opt/pw
COPY DEPENDENCIES.md .
RUN apt-get update && apt-get install -y \
    $(cat DEPENDENCIES.md) \
    file \
    parallel \
    xclip \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

FROM base AS pw
WORKDIR /opt/pw
COPY src src
COPY examples examples
COPY plugins plugins
COPY version.txt .
RUN ln -s /opt/pw/src/pw /usr/local/bin/pw
WORKDIR /root
COPY docker/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

FROM pw AS test
WORKDIR /opt/pw
COPY test test
RUN test/bats/bin/bats --jobs $(nproc) test
