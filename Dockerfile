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

ARG VARIANT="latest"
FROM ghcr.io/jessenich/alpine:"$VARIANT" as base

LABEL maintainer="Jesse N. <jesse@keplerdev.com>" \
      org.opencontainers.image.url="https://github.com/jessenich/docker-alpine-zsh" \
      org.opencontainers.image.source="https://github.com/jessenich/docker-alpine-zsh" \
      org.opencontainers.image.authors="Jesse N. <jesse@keplerdev.com>" \
      org.opencontainers.image.vendor="Kepler Development"

ENV VARIANT=$VARIANT \
    LANG=C.UTF-8 \
    TZ="${TZ:-America/New_York}" \
    RUNNING_IN_DOCKER="true"

COPY ./rootfs /

USER root
RUN apk add --update --no-cache bash
SHELL [ "/bin/bash", "-c" ]
RUN apk add --update --no-cache zsh
SHELL [ "/usr/bin/zsh", "-c" ]

FROM base as download
ARG OMZ_VERSION=master
ENV OMZ_BRANCH=${OMZ_VERSION} \
    ZSH_DOTFILES="/home/$USER/.zsh"

RUN apk add --update --no-cache git;

RUN BRANCH=$OMZ_BRANCH && \
    ZSH="$ZSH_DOTFILES/ohmyzsh" && \
    mkdir -p "$ZSH" && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/jessenich/ohmyzsh/${OMZ_VERSION}/tools/quick-install.sh)" \
        --branch "jesse/main" \
        --zsh "$HOME/.zsh" \
        --no-banner

RUN cd "$ZSH" || exit 1 && \
    git remote add upstream https://github.com/robbyrussell/oh-my-zsh.git

FROM base as final



USER "$USER"
WORKDIR "/home/$USER"
CMD [ "exec", "/usr/bin/zsh", "-l" ]
