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

ARG ALPINE_VERSION=

FROM alpine:"${ALPINE_VERSION:-latest}" as deps

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"

ENV USER_LOGIN_SHELL="/bin/zsh" \
    USER_LOGIN_SHELL_FALLBACK="/bin/ash" \
    TZ="America/NewYork" \
    RUNNING_IN_DOCKER="true"
    
RUN apk update

# Add dependencies
RUN apk add \ 
        ca-certificates \
        nano \
        nano-syntax \
        rsync \
        curl \
        wget \
        jq \
        yq
    
# Add optional corresponding documentation packages
ARG NO_DOCS=
ENV NO_DOCS="${NO_DOCS:-false}"

RUN if [ "${NO_DOCS}" = "false" ]; then \
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

RUN apk update
RUN apk add zsh

RUN echo "# valid login shells" > /etc/shells && \
    echo "/bin/zsh" >> /etc/shells && \
    echo "/bin/bash" >> /etc/shells && \
    echo "/bin/ash" >> /etc/shells && \
    echo "/bin/sh" >> /etc/shells

RUN apk add \
        zsh-calendar \
        zsh-zftp \
        zsh-vcs \
        apk-tools-zsh-completion \
        shadow \
        zsh-autosuggestions \
        rsync-zsh-completion \
        yq-zsh-completion

RUN if [ "${NO_DOCS}" = "false" ]; then \
        apk add \
            zsh-doc \
            zsh-syntax-highlighting-doc; \
    fi
    
RUN rm -rf /var/cache/apk/*

FROM zsh as ohmyzsh-install

WORKDIR /root

RUN apk add git

RUN /bin/zsh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
COPY resources/zshrc /root/.zshrc

FROM zsh as ohmyzsh

COPY --from=ohmyzsh-install /root/.zshrc /root/.zshrc
COPY --from=ohmyzsh-install /root/.oh-my-zsh /root/.oh-my-zsh

ENTRYPOINT [ "exec", "/bin/zsh" ]

FROM ohmyzsh as glibc

ARG GLIBC_VERSION=
ENV GLIBC_VERSION="${GLIBC_VERSION:-2.33-r0}"

# Download and install glibc
RUN curl -sSLo /etc/apk/keys/sgerrand.rsa.pub "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" && \
    curl -sSLo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
    curl -sSLo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
    apk add glibc-bin.apk glibc.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    rm glibc.apk && \
    rm glibc-bin.apk;
