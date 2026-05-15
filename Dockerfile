
FROM amd64/alpine:3.22.4

ARG INSTALL_IG="true"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

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

RUN if [ "$INSTALL_IG" = "true" ]; then \
        echo "Installing Inspektor Gadget..." && \
        IG_VERSION=$(curl -s https://api.github.com/repos/inspektor-gadget/inspektor-gadget/releases/latest | jq -r .tag_name) && \
        IG_ARCH="amd64" && \
        curl -sL "https://github.com/inspektor-gadget/inspektor-gadget/releases/download/${IG_VERSION}/ig-linux-${IG_ARCH}-${IG_VERSION}.tar.gz" | tar -C /usr/local/bin -xzf - ig; \
    else \
        echo "INSTALL_IG is false. Skipping Inspektor Gadget installation."; \
    fi
