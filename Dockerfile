## MIT License
##
## Copyright (c) 2022 Jesse N. <jesse@keplerdev.com>
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
ARG DEFAULT_OMZ_THEME="agnoster"
FROM ghcr.io/jessenich/alpine:"$VARIANT" as base

LABEL maintainer="jessenich <https://github.com/jessenich>" \
      license="https://github.com/jessenich/docker-alpine-zsh/blob/main/LICENSE" \
      org.opencontainers.image.url="https://github.com/jessenich/docker-alpine-zsh" \
      org.opencontainers.image.source="https://github.com/jessenich/docker-alpine-zsh/blob/main/Dockerfile" \
      org.opencontainers.image.authors="jessenich <https://github.com/jessenich>" \
      org.opencontainers.image.description="Minimal Alpine based image containing just ZSH and Oh-My-ZSH!"

ARG OMZ_VERSION="jesse/main"
ARG OMZ_SOURCE="https://raw.githubusercontent.com/jessenich/ohmyzsh/${OMZ_VERSION}/tools/quick-install.sh"
ARG ZSH_DOTFILES="/home/$USER/.zsh"
ARG ZSH="$ZSH_DOTFILES/ohmyzsh"

RUN apk add --update --no-cache \
        bash \
        curl \
        git

RUN  && \
    mkdir -p "$ZSH" && \
    curl -fsSL $OMZ_SOURCE -- | bash \
        --branch "$$OMZ_VERSION" \
        --zsh "$ZSH_DOTFILES" \
        --no-banner

FROM base as final

ENV VARIANT=$VARIANT \
    LANG=C.UTF-8 \
    TZ="${TZ:-America/New_York}" \
    RUNNING_IN_DOCKER="true"

COPY ./rootfs /

USER root
RUN apk add --update --no-cache zsh
SHELL [ "/usr/bin/zsh" ]

USER "$USER"
WORKDIR "/home/$USER"
CMD [ "exec", "/usr/bin/zsh", "-l" ]
