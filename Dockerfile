# Use a minimal Alpine image with a fixed version
FROM amd64/alpine:3.20.1

# Install required tools
RUN apk add --no-cache \
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
        sudo  # Install sudo

# Upgrade installed packages
RUN apk update && apk upgrade

# Create a non-root user
RUN addgroup -S debuggroup && adduser -S debuguser -G debuggroup \
    && echo "debuguser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/debuguser  # Allow sudo without password

# Copy entry script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
