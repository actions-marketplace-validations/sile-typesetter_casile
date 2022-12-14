#syntax=docker/dockerfile:1.2

ARG ARCHTAG

FROM docker.io/library/archlinux:$ARCHTAG AS base

# Setup Caleb’s hosted Arch repository with prebuilt dependencies
RUN pacman-key --init && pacman-key --populate
RUN sed -i  /etc/pacman.conf -e \
	'/^.community/{n;n;s!^!\n\[alerque\]\nServer = https://arch.alerque.com/$arch\n!}'
RUN pacman-key --recv-keys 63CC496475267693 && pacman-key --lsign-key 63CC496475267693

# This hack can convince Docker its cache is obsolete; e.g. when the contents
# of downloaded resources have changed since being fetched. It's helpful to have
# this as a separate layer because it saves time for local builds. Incrementing
# this when pushing dependency updates to Caleb's Arch user repository or just
# when the remote Docker Hub builds die should be enough.
ARG DOCKER_HUB_CACHE=1

ARG RUNTIME_DEPS

# Freshen all base system packages
RUN pacman --needed --noconfirm -Syuq && yes | pacman -Sccq

# Install run-time dependecies
RUN pacman --needed --noconfirm -Sq $RUNTIME_DEPS && yes | pacman -Sccq

RUN chsh -s /usr/bin/zsh && echo 'autoload -U zmv' >> /etc/zsh/zprofile

# Setup separate image for build so we don’t bloat the final image
FROM base AS builder

ARG BUILD_DEPS

# Install build time dependecies
RUN pacman --needed --noconfirm -Sq $BUILD_DEPS && yes | pacman -Sccq

# Set at build time, forces Docker’s layer caching to reset at this point
ARG REVISION

COPY ./ /src
WORKDIR /src

# GitHub Actions builder stopped providing git history :(
# See feature request at https://github.com/actions/runner/issues/767
RUN build-aux/bootstrap-docker.sh

RUN ./bootstrap.sh
RUN ./configure
RUN make
RUN make check-version
RUN make install DESTDIR=/pkgdir
RUN node-prune /pkgdir/usr/local/share/casile/node_modules

FROM base AS final

# Same args as above, repeated because they went out of scope with FROM
ARG REVISION
ARG VERSION

# Allow `su` with no root password so non-priv users can install dependencies
RUN sed -i -e '/.so$/s/$/ nullok/' /etc/pam.d/su

LABEL org.opencontainers.image.title="CaSILE"
LABEL org.opencontainers.image.description="A containerized version of the CaSILE toolkit, a book publishing workflow employing SILE and other wizardry"
LABEL org.opencontainers.image.authors="Caleb Maclennan <caleb@alerque.com>"
LABEL org.opencontainers.image.licenses="AGPL-3.0"
LABEL org.opencontainers.image.url="https://github.com/sile-typesetter/casile/pkgs/container/casile"
LABEL org.opencontainers.image.source="https://github.com/sile-typesetter/casile"
LABEL org.opencontainers.image.version="v$VERSION"
LABEL org.opencontainers.image.revision="$REVISION"

COPY build-aux/docker-fontconfig.conf /etc/fonts/conf.d/99-docker.conf

COPY --from=builder /pkgdir /
RUN casile --version

WORKDIR /data
ENTRYPOINT ["casile"]
