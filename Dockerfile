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
FROM ghcr.io/jessenich/alpine:"${VARIANT}"

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"
LABEL org.opencontainers.image.source="https://github.com/jessenich/docker-alpine-zsh/blob/main/Dockerfile"

ENV VARIANT=${VARIANT} \
    TZ="${TZ:-America/New_York}" \
    RUNNING_IN_DOCKER="true"

USER root
RUN apk add --update --no-cache \
        git \
        zsh \
        zsh-syntax-highlighting \
        zsh-autosuggestions \
        rsync-zsh-completion \
        yq-zsh-completion;

RUN chmod 0640 /etc/shadow

COPY ./rootfs /

RUN /bin/zsh /usr/local/sbin/install-oh-my-zsh.sh 2>&1 && \
    rm -f /usr/local/sbin/install-oh-my-zsh.sh

USER "$USER"
WORKDIR "/home/${USER}"
CMD "/bin/zsh"
