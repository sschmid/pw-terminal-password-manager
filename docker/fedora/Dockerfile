FROM fedora:latest AS base
WORKDIR /usr/local/opt/pw
COPY DEPENDENCIES.md .
RUN dnf install -y \
    $(cat DEPENDENCIES.md) \
    file \
    parallel \
    procps-ng \
    xclip \
    xorg-x11-server-Xvfb \
    && dnf clean all \
    && rm -rf /var/cache/yum

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
RUN test/bats/bin/bats --jobs $(nproc) test
