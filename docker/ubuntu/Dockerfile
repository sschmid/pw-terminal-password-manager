FROM ubuntu:latest AS base
RUN apt-get update && apt-get install -y \
    file \
    fzf \
    gnupg \
    keepassxc \
    locales \
    xclip \
    xvfb \
    && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8

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
