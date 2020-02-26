# Start from the official Jekyll 'Builder' image
# which contains everything we need to run Jekyll
# normally. Jekyll Builder is built upon Ruby's image
# which is built upon Alpine Linux.
FROM jekyll/builder:latest AS base


## Sections of this script for building GHC-Up are modified from:
## https://github.com/jkachmar/alpine-haskell-stack/blob/master/Dockerfile

###################################################
#   GHC-Up
###################################################

# Note: This layer will also be used as the base for stack-tooling
FROM base as ghc-up

# Must be one of 'gmp' or 'simple'; used to build GHC with support for either
# 'integer-gmp' (with 'libgmp') or 'integer-simple'
#
# Default to building with 'integer-gmp' and 'libgmp' support
# Note: 'simple' is untested since modifications
ARG GHC_BUILD_TYPE=gmp

# Must be a valid GHC version number, only tested with 8.6.5
#
# Default to GHC version 8.6.5
ARG GHC_VERSION=8.6.5

# Add ghcup's bin directory to the PATH so that the versions of GHC it builds
# are available in the build layers
ENV GHCUP_INSTALL_BASE_PREFIX=/
ENV PATH=/.ghcup/bin:$PATH

# Use a specific version of ghcup
ENV GHCUP_VERSION=0.0.7
# We're going to validate the checksum to make sure it downloaded properly
ENV GHCUP_SHA256="b4b200d896eb45b56c89d0cfadfcf544a24759a6ffac029982821cc96b2faedb  ghcup"

# Install the basic required dependencies to run 'ghcup' and 'stack'
RUN apk upgrade --no-cache &&\
    apk add --no-cache \
    curl \
    gcc \
    git \
    libc-dev \
    xz &&\
    if [ "${GHC_BUILD_TYPE}" = "gmp" ]; then \
    echo "Installing 'libgmp'" &&\
    apk add --no-cache gmp-dev; \
    fi

# Download, verify, and install ghcup
RUN echo "Downloading and installing ghcup" &&\
    cd /tmp &&\
    wget -P /tmp/ "https://gitlab.haskell.org/haskell/ghcup/raw/${GHCUP_VERSION}/ghcup" &&\
    if ! echo -n "${GHCUP_SHA256}" | sha256sum -c -; then \
    echo "ghcup-${GHCUP_VERSION} checksum failed" >&2 &&\
    exit 1 ;\
    fi ;\
    mv /tmp/ghcup /usr/bin/ghcup &&\
    chmod +x /usr/bin/ghcup
