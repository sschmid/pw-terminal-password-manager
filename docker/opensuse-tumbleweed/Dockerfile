FROM opensuse/tumbleweed:latest AS base
WORKDIR /usr/local/opt/pw
COPY DEPENDENCIES.md .
RUN zypper --non-interactive install --no-recommends \
    $(cat DEPENDENCIES.md) \
    file \
    gawk \
    gnu_parallel \
    xclip \
    xorg-x11-server-Xvfb \
    && zypper clean -a \
    && rm -rf /var/cache/zypp/*

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
