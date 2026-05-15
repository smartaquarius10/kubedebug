# Fix DL3007: Pin a specific version instead of 'latest'
FROM amd64/alpine:3.22.4

# Fix DL4006: Set pipefail for the curl | tar command later in the file
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# Fix DL3018: Ignore apk version pinning (See explanation below)
# hadolint ignore=DL3018
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache \
        ca-certificates \
        krb5-libs \
        libgcc \
        libintl \
        libssl3 \
        libstdc++ \
        bind-tools \
        curl \
        traceroute \
        zlib \
        tshark \
        busybox-extras \
        wget \
        jq \
        tar

# Fix SC2086: Double quote variables
ARG IG_VERSION=v0.51.1
# RUN IG_VERSION=$(curl -s https://api.github.com/repos/inspektor-gadget/inspektor-gadget/releases/latest | jq -r .tag_name) \
RUN IG_ARCH="amd64" \
 && IG_VERSION=v0.51.1 \
 && curl -sL "https://github.com/inspektor-gadget/inspektor-gadget/releases/download/${IG_VERSION}/ig-linux-${IG_ARCH}-${IG_VERSION}.tar.gz" | tar -C /usr/local/bin -xzf - ig
