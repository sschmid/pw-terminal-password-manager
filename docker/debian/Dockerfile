FROM debian:latest AS base
WORKDIR /usr/local/opt/pw
COPY DEPENDENCIES.md .
RUN apt-get update && apt-get install -y \
    $(cat DEPENDENCIES.md) \
    file \
    xclip \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

FROM base AS pw
WORKDIR /usr/local/opt/pw
COPY src src
COPY plugins plugins
COPY version.txt .
RUN ln -s /usr/local/opt/pw/src/pw /usr/local/bin/pw
WORKDIR /root
COPY docker/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

FROM pw AS test
WORKDIR /usr/local/opt/pw
COPY test test
RUN test/bats/bin/bats test
