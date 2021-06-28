## MIT License
## 
## Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.

ARG ALPINE_VERSION="latest"

FROM alpine:"${ALPINE_VERSION:-latest}" as deps

ARG NO_DOCS=
ARG TZ=
ARG USER_LOGIN_SHELL=
ARG USER_LOGIN_FALLBACK_SHELL=

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"

ENV ALPINE_VERSION=${ALPINE_VERSION} \
    NO_DOCS="${NO_DOCS:+true}" \
    USER_LOGIN_SHELL="${USER_LOGIN_SHELL:-/bin/zsh}" \
    USER_LOGIN_SHELL_FALLBACK="${USER_LOGIN_FALLBACK_SHELL:-/bin/ash}" \
    TZ="${TZ:-America/NewYork}" \
    RUNNING_IN_DOCKER="true" \
    DISTRIBUTION="$(uname -a)"

# Add dependencies
RUN apk update && \
    apk add \ 
    zsh \
    zsh-syntax-highlighting \
    zsh-autosuggestions \
    ca-certificates \
    nano \
    nano-syntax \
    shadow \
    rsync \
    rsync-zsh-completion \
    curl \
    wget \
    jq \
    yq \
    yq-zsh-completion

# Add optional corresponding documentation packages
RUN if [ "${NO_DOCS}" != "true" ]; then \
    apk add \
    man-pages \
    man-db \
    man-db-doc \
    nano-doc \
    curl-doc \
    wget-doc \
    jq-doc \
    yq-doc; \
    fi

RUN rm -rf /var/cache/apk/*

FROM deps as zsh

RUN echo "# valid login shells" > /etc/shells && \
    echo "/bin/zsh" >> /etc/shells && \
    echo "/bin/bash" >> /etc/shells && \
    echo "/bin/ash" >> /etc/shells && \
    echo "/bin/sh" >> /etc/shells;

RUN if [ "${NO_DOCS}" != "true" ]; \ 
    then \
    apk add \
    zsh-doc \
    zsh-syntax-highlighting-doc; \
    fi

RUN rm -rf /var/cache/apk/*

FROM zsh as ohmyzsh-install

ARG NO_OHMYZSH=
ENV NO_OHMYZSH="${NO_OHMYZSH:+true}"

COPY resources/tmp/docker-build/install-ohmyzsh.sh /tmp/docker-build/install-ohmyzsh.sh

RUN if [ "${NO_OHMYZSH}" = "true" ]; then \
    chmod +x /tmp/docker-build/install-ohmyzsh.sh && \
    /tmp/docker-build/install-ohmyzsh.sh; \
    fi

FROM zsh as ohmyzsh
ARG NO_OHMYZSH=
ENV NO_OHMYZSH="${NO_OHMYZSH:+true}"

COPY resources/tmp/docker-build/zshrc /tmp/docker-build/zshrc
COPY 

ENTRYPOINT [ "exec", "/bin/zsh" ]

FROM ohmyzsh as glibc

ARG GLIBC_VERSION=
ENV GLIBC_VERSION="${GLIBC_VERSION:-2.33-r0}"

# Download and install glibc
RUN if [ "${GLIBC_VERSION}" != "none" ]; \
    then \
    curl -sSLo /etc/apk/keys/sgerrand.rsa.pub "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" && \
    curl -sSLo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
    curl -sSLo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
    apk add glibc-bin.apk glibc.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    rm glibc.apk && \
    rm glibc-bin.apk; \
    fi
