FROM fedora:latest AS base
WORKDIR /opt/pw
COPY DEPENDENCIES.md .
RUN dnf install -y \
    $(cat DEPENDENCIES.md) \
    awk \
    file \
    parallel \
    procps-ng \
    xclip \
    xorg-x11-server-Xvfb \
    && dnf clean all \
    && rm -rf /var/cache/yum

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
