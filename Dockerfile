FROM amd64/alpine:latest

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
        busybox-extras 

RUN apk update && apk upgrade
RUN apk add --no-cache wget jq tar \
 && LATEST=$(wget -qO- https://api.github.com/repos/tsenart/vegeta/releases/latest | jq -r .tag_name) \
 && wget -q https://github.com/tsenart/vegeta/releases/download/${LATEST}/vegeta_${LATEST#v}_linux_amd64.tar.gz -O /tmp/vegeta.tar.gz \
 && tar -xzf /tmp/vegeta.tar.gz -C /usr/local/bin vegeta \
 && rm /tmp/vegeta.tar.gz 

RUN IG_VERSION=$(curl -s https://api.github.com/repos/inspektor-gadget/inspektor-gadget/releases/latest | jq -r .tag_name) \
  && IG_ARCH=amd64 \
  && curl -sL https://github.com/inspektor-gadget/inspektor-gadget/releases/download/${IG_VERSION}/ig-linux-${IG_ARCH}-${IG_VERSION}.tar.gz | tar -C /usr/local/bin -xzf - ig
    
ENV \    
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
