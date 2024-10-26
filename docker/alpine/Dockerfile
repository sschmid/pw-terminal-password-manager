ARG BASH_VERSION=5.2
FROM bash:${BASH_VERSION} AS base
RUN apk add --no-cache \
    fzf \
    gnupg \
    keepassxc \
    xclip \
    xvfb

FROM base AS pw
WORKDIR /usr/local/opt/pw
COPY src src
COPY version.txt .
RUN ln -s /usr/local/opt/pw/src/pw /usr/local/bin/pw
WORKDIR /root
COPY docker/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

FROM pw AS test
WORKDIR /usr/local/opt/pw
COPY test test
RUN test/bats/bin/bats test
