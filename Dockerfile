FROM amd64/alpine:latest

RUN apk add --no-cache \
        ca-certificates \
        \
        # .NET dependencies
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
        busybox-extras 

RUN apk update && apk upgrade
RUN wget -O /usr/local/bin/hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64 \
    && chmod +x /usr/local/bin/hey
    
ENV \    
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
