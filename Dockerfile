ARG ALPINE_VERSION=

FROM alpine:"${ALPINE_VERSION:-3.13}" as deps

LABEL maintainer Jesse N. <jesse@keplerdev.com>

ENV USER_LOGIN_SHELL="/bin/zsh" \
    USER_LOGIN_SHELL_FALLBACK="/bin/ash" \
    TZ="America/NewYork" \
    RUNNING_IN_DOCKER="true"

# Add dependencies
RUN apk add --update --no-cache \
    ca-certificates \
    nano \
    nano-syntax \
    rsync \
    curl \
    wget \
    jq \
    yq
    
# Add optional corresponding documentation packages
ARG INCLUDE_DOCS=
ENV INCLUDE_DOCS="${INCLUDE_DOCS:-true}"

RUN if "${INCLUDE_DOCS}"="true"; then \
    apk add --update --no-cache \
        man-pages \
        man-db \
        man-db-doc \
        nano-doc \
        curl-doc \
        wget-doc \
        jq-doc \
        yq-doc fi

FROM deps as ohmyzsh

RUN apk add --update --no-cache zsh

RUN echo "# valid login shells" > /etc/shells && \
    ehco "/bin/zsh" >> /etc/shells && \
    echo "/bin/bash" >> /etc/shells && \
    echo "/bin/ash" >> /etc/shells && \
    echo "/bin/sh" >> /etc/shells

RUN apk add --update --no-cache \
    zsh-calendar \
    zsh-zftp \
    zsh-vcs \
    apk-tools-zsh-completion \
    shadow \
    zsh-autosuggestions \
    rsync-zsh-completion \
    yq-zsh-completion

RUN if "${INCLUDE_DOCS}"="true" then; \
    apk add --update --no-cache \
        zsh-doc \
        zsh-syntax-highlighting-doc fi

WORKDIR /root

RUN /bin/zsh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
COPY resources/zshrc /root/.zshrc

FROM ohmyzsh as glibc

ARG GLIBC_VERSION=
ENV GLIBC_VERSION="${GLIBC_VERSION:-2.33-r0}"

# Download and install glibc
RUN curl -sSLo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
  curl -sSLo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
  curl -sSLo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
  apk add glibc-bin.apk glibc.apk && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf
