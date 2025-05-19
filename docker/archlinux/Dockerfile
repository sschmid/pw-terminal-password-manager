FROM archlinux:latest AS base
# FROM --platform=linux/amd64 archlinux:latest AS base
WORKDIR /opt/pw
COPY DEPENDENCIES.md .
RUN pacman -Syu --noconfirm && pacman -S --noconfirm --needed \
    $(cat DEPENDENCIES.md) \
    parallel \
    xclip \
    xorg-server-xvfb \
    && pacman -Scc --noconfirm

FROM base AS pw
WORKDIR /opt/pw
COPY src src
COPY config config
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
